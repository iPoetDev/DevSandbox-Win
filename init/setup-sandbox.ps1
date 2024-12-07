# PowerShell Development Sandbox Setup Script
[CmdletBinding()]
param(
    [Parameter(HelpMessage = 'Include PSProfile installation script in sandbox')]
    [switch]$IncludeInstaller,

    [Parameter(HelpMessage = 'Include PSProfile test script in sandbox')]
    [switch]$IncludeTester,

    [Parameter(HelpMessage = 'Automatically run installer after sandbox starts')]
    [switch]$AutoInstall,

    [Parameter(HelpMessage = 'Automatically run tests after sandbox starts')]
    [switch]$AutoTest,

    [Parameter(HelpMessage = 'Force download of offline packages')]
    [switch]$ForcePackageDownload
)

$ErrorActionPreference = 'Stop'

# Initialize logging
$logRoot = Join-Path $env:USERPROFILE 'Environments\PSProfile\Logs'
$logFile = Join-Path $logRoot "sandbox-setup-$(Get-Date -Format 'yyyyMMdd-HHmmss').log"
if (!(Test-Path $logRoot)) {
    New-Item -Path $logRoot -ItemType Directory -Force | Out-Null
}

function Write-Log {
    param(
        [Parameter(Mandatory)]
        [string]$Message,
        [ValidateSet('Info', 'Warning', 'Error')]
        [string]$Level = 'Info'
    )

    $timestamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
    $logMessage = "[$timestamp] [$Level] $Message"
    Add-Content -Path $logFile -Value $logMessage

    switch ($Level) {
        'Info' { Write-Information $Message }
        'Warning' { Write-Warning $Message }
        'Error' { Write-Error $Message }
    }
}

# Function to validate manifest structure
function Test-ManifestStructure {
    param([object]$Manifest)

    $requiredSections = @(
        'sandboxConfig',
        'environment',
        'userProfiles',
        'paths',
        'installations',
        'scripts'
    )

    $validationErrors = @()

    # Check required sections
    foreach ($section in $requiredSections) {
        if (!$Manifest.$section) {
            $validationErrors += "Missing required section: $section"
        }
    }

    # Validate package configurations
    if ($Manifest.installations.sequence) {
        foreach ($package in $Manifest.installations.sequence) {
            $config = $Manifest.paths.packages.$package
            if (!$config) {
                $validationErrors += "Package '$package' in sequence not found in package configurations"
                continue
            }

            if (!$config.type) {
                $validationErrors += "Package '$package' missing required 'type' property"
                continue
            }

            $validType = $Manifest.installations.packageTypes.$($config.type)
            if (!$validType) {
                $validationErrors += "Package '$package' has invalid type: $($config.type)"
                continue
            }

            # Type-specific validation
            switch ($config.type) {
                'direct' {
                    if (!$config.path) { $validationErrors += "Package '$package' missing required 'path' property" }
                }
                'dotnet-tool' {
                    if (!$config.tools) { $validationErrors += "Package '$package' missing required 'tools' configuration" }
                }
                'self-extracting' {
                    if (!$config.installer) { $validationErrors += "Package '$package' missing required 'installer' property" }
                    if (!$config.silent) { $validationErrors += "Package '$package' missing required 'silent' property" }
                }
                'archive' {
                    if (!$config.installer) { $validationErrors += "Package '$package' missing required 'installer' property" }
                }
            }
        }
    }
    else {
        $validationErrors += "Missing required installation sequence"
    }

    return $validationErrors
}

# Load and validate manifest
try {
    $manifestPath = Join-Path $PSScriptRoot 'setup-manifest.json'
    if (!(Test-Path $manifestPath)) {
        throw "Setup manifest not found at: $manifestPath"
    }

    Write-Log "Loading manifest from: $manifestPath" -Level Info
    $manifest = Get-Content $manifestPath -Raw | ConvertFrom-Json

    $manifestErrors = Test-ManifestStructure -Manifest $manifest
    if ($manifestErrors) {
        $errorMessage = "Manifest validation failed:`n" + ($manifestErrors -join "`n")
        Write-Log $errorMessage -Level Error
        throw $errorMessage
    }

    Write-Log "Manifest validation successful" -Level Info
}
catch {
    Write-Log "Failed to load or validate manifest: $_" -Level Error
    throw
}

# Function to resolve environment variables in paths
function Resolve-EnvPath {
    param(
        [string]$Path,
        [switch]$PreferDEnv
    )
    
    $resolvedPath = [System.Environment]::ExpandEnvironmentVariables($Path)
    $resolvedPath = $resolvedPath.Replace('/', '\')
    
    # If PreferDEnv is specified and this is a PSProfile path, use D:\Env instead
    if ($PreferDEnv -and $resolvedPath -like "*\Environments\PSProfile*") {
        $resolvedPath = $resolvedPath -replace [regex]::Escape("$env:USERPROFILE\Environments\PSProfile"), "D:\Env\PSProfile"
    }
    
    return $resolvedPath
}

# Validate and normalize paths
$paths = @{
    SandboxRoot = "C:\Users\Charles\.pwsh\sandbox"
    SandboxDev = "D:\Env\PSProfile\DevCode"
}

# Ensure host paths exist
if (-not (Test-Path $paths.SandboxDev)) {
    New-Item -Path $paths.SandboxDev -ItemType Directory -Force | Out-Null
    Write-Log "Created missing directory: $($paths.SandboxDev)" -Level Info
}

# Convert local path to UNC path
$computerName = $env:COMPUTERNAME
$devPath = "\\$computerName\D$\Env\PSProfile\DevCode"
$packagesPath = "\\$computerName\D$\Env\packages"

# Generate sandbox configuration with required mappings
$sandboxConfig = @"
<?xml version="1.0" encoding="UTF-8"?>
<Configuration>
    <MappedFolders>
        <MappedFolder>
            <HostFolder>C:\Windows</HostFolder>
            <SandboxFolder>C:\Test</SandboxFolder>
            <ReadOnly>true</ReadOnly>
        </MappedFolder>
        <MappedFolder>
            <HostFolder>$devPath</HostFolder>
            <SandboxFolder>C:\Users\WDAGUtilityAccount\Desktop\DevCode</SandboxFolder>
            <ReadOnly>false</ReadOnly>
        </MappedFolder>
        <MappedFolder>
            <HostFolder>$packagesPath</HostFolder>
            <SandboxFolder>C:\Packages</SandboxFolder>
            <ReadOnly>true</ReadOnly>
        </MappedFolder>
    </MappedFolders>
    <LogonCommand>
        <Command>powershell -NoProfile -ExecutionPolicy Bypass -Command "Set-Location C:\Users\WDAGUtilityAccount\Desktop\DevCode"</Command>
    </LogonCommand>
    <MemoryInMB>8192</MemoryInMB>
    <vGPU>Enable</vGPU>
    <Networking>Enable</Networking>
</Configuration>
"@

# Ensure sandbox root exists
if (-not (Test-Path $paths.SandboxRoot)) {
    New-Item -Path $paths.SandboxRoot -ItemType Directory -Force | Out-Null
}

# Save the sandbox configuration
$sandboxConfigPath = Join-Path $paths.SandboxRoot "sandbox-config.wsb"
[System.IO.File]::WriteAllText($sandboxConfigPath, $sandboxConfig, [System.Text.Encoding]::UTF8)

Write-Log "Generated sandbox configuration at: $sandboxConfigPath" -Level Info

# Function to write status messages with proper formatting
function Write-Status {
    param(
        [Parameter(Mandatory)]
        [string]$Message,
        [ValidateSet('Info', 'Warning', 'Error')]
        [string]$Level = 'Info'
    )

    $timestamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
    switch ($Level) {
        'Info' { Write-Information "[$timestamp] $Message" }
        'Warning' { Write-Warning "[$timestamp] $Message" }
        'Error' { Write-Error "[$timestamp] $Message" }
    }
}

# Function to safely execute commands with error handling
function Invoke-SafeCommand {
    param(
        [Parameter(Mandatory)]
        [scriptblock]$ScriptBlock,
        [string]$ErrorMessage
    )

    try {
        & $ScriptBlock
        return $true
    } catch {
        Write-Status -Level Error -Message "$ErrorMessage`: $_"
        return $false
    }
}

# Function to install packages based on type with proper variable scoping
function Install-PackageByType {
    param (
        [Parameter(Mandatory)]
        [string]$PackageName,
        [Parameter(Mandatory)]
        [object]$PackageConfig
    )

    Write-Status -Message "Installing $PackageName..." -Level Info

    try {
        $type = $PackageConfig.type
        $packageType = $manifest.installations.packageTypes.$type

        if (!$packageType) {
            $errorMessage = "Unknown package type: $type"
            Write-Log $errorMessage -Level Warning
            return $false
        }

        switch ($type) {
            'direct' {
                $sourcePath = $PackageConfig.path
                $targetPath = Join-Path $manifest.paths.programFiles.x64 "$PackageName.exe"

                if (!(Test-Path $sourcePath)) {
                    Write-Log "Package not found: $PackageName at path: $sourcePath" -Level Warning
                    Write-Log "Manual installation URL: $(Get-ManualInstallationUrl -PackageName $PackageName -PackageConfig $PackageConfig)" -Level Info
                    return $false
                }

                Copy-Item -Path $sourcePath -Destination $targetPath -Force
                $env:Path = "$([System.IO.Path]::GetDirectoryName($targetPath));$env:Path"
            }
            'dotnet-tool' {
                foreach ($tool in $PackageConfig.tools.PSObject.Properties) {
                    $toolName = $tool.Value.name
                    $version = $tool.Value.version
                    $command = "$($packageType.installMethod) $($toolName) --version $($version)"

                    if (!(Invoke-Expression $command)) {
                        Write-Log "Failed to install .NET tool: $($toolName)" -Level Warning
                        return $false
                    }
                }
            }
            'self-extracting' {
                $installer = $PackageConfig.installer
                if (!(Test-Path $installer)) {
                    Write-Log "Package not found: $PackageName at path: $installer" -Level Warning
                    Write-Log "Manual installation URL: $(Get-ManualInstallationUrl -PackageName $PackageName -PackageConfig $PackageConfig)" -Level Info
                    return $false
                }

                $process = Start-Process -FilePath $installer `
                    -ArgumentList $PackageConfig.silent `
                    -Wait -PassThru -NoNewWindow

                if ($process.ExitCode -ne 0) {
                    Write-Log "Installation failed for $PackageName with exit code: $($process.ExitCode)" -Level Warning
                    return $false
                }

                if ($PackageConfig.config) {
                    foreach ($setting in $PackageConfig.config.PSObject.Properties) {
                        git config --global $setting.Name $setting.Value
                    }
                }
            }
            'archive' {
                $installer = $PackageConfig.installer
                if (!(Test-Path $installer)) {
                    Write-Log "Package not found: $PackageName at path: $installer" -Level Warning
                    Write-Log "Manual installation URL: $(Get-ManualInstallationUrl -PackageName $PackageName -PackageConfig $PackageConfig)" -Level Info
                    return $false
                }

                $destinationPath = switch ($PackageName) {
                    'powershell' { Join-Path $manifest.paths.programFiles.x64 'PowerShell' }
                    'vscode' { Join-Path $manifest.paths.programFiles.x64 'Microsoft VS Code' }
                    default { Join-Path $manifest.paths.programFiles.x64 $PackageName }
                }

                # Create destination if it doesn't exist
                if (!(Test-Path $destinationPath)) {
                    New-Item -Path $destinationPath -ItemType Directory -Force | Out-Null
                }

                # Extract archive
                Expand-Archive -Path $installer -DestinationPath $destinationPath -Force

                # Post-extraction setup
                switch ($PackageName) {
                    'powershell' {
                        $pwshPath = Join-Path $destinationPath 'pwsh.exe'
                        if (Test-Path $pwshPath) {
                            $env:Path = "$destinationPath;$env:Path"

                            foreach ($module in $PackageConfig.modules.PSObject.Properties) {
                                $moduleConfig = $module.Value
                                $moduleParams = @{
                                    Name = $module.Name
                                    RequiredVersion = $moduleConfig.version
                                    Repository = $moduleConfig.repository
                                    Force = $true
                                }

                                & $pwshPath -NoProfile -Command {
                                    param($params)
                                    Install-Module @params
                                } -Args $moduleParams
                            }
                        } else {
                            Write-Log "PowerShell executable not found at: $pwshPath" -Level Warning
                            return $false
                        }
                    }
                    'vscode' {
                        foreach ($ext in $PackageConfig.extensions.PSObject.Properties) {
                            $extConfig = $ext.Value
                            $extId = "$($extConfig.publisher).$($extConfig.name)"
                            $vsixPath = Join-Path $manifest.paths.packages.root "vscode\extensions\$extId-$($extConfig.version).vsix"

                            if (Test-Path $vsixPath) {
                                Write-Status -Message "Installing VSCode extension: $extId v$($extConfig.version)" -Level Info
                                & code --install-extension $vsixPath
                            } else {
                                Write-Log "VSCode extension not found: $vsixPath" -Level Warning
                            }
                        }
                    }
                }
            }
        }

        Write-Status -Message "Successfully installed $PackageName" -Level Info
        return $true
    }
    catch {
        Write-Log "Failed to install $PackageName : $_" -Level Warning
        Write-Log "Manual installation URL: $(Get-ManualInstallationUrl -PackageName $PackageName -PackageConfig $PackageConfig)" -Level Info
        return $false
    }
}

# Function to install required packages with proper error aggregation
function Install-RequiredPackages {
    Write-Status -Message "Starting package installation sequence..." -Level Info

    $skipped = @()

    foreach ($package in $manifest.installations.sequence) {
        $config = $manifest.paths.packages.$package
        if (!(Install-PackageByType -PackageName $package -PackageConfig $config)) {
            $skipped += $package
            Write-Log "Skipped package installation: $package" -Level Warning
        }
    }

    if ($skipped.Count -gt 0) {
        Write-Log "The following packages were skipped: $($skipped -join ', ')" -Level Warning
    }

    Write-Status -Message "Package installation complete" -Level Info
}

# Function to get manual installation URL
function Get-ManualInstallationUrl {
    param(
        [Parameter(Mandatory)]
        [string]$PackageName,
        [Parameter(Mandatory)]
        [object]$PackageConfig
    )

    switch ($PackageName) {
        'powershell' {
            return "https://github.com/PowerShell/PowerShell/releases/tag/v$($PackageConfig.version)"
        }
        'git' {
            return "https://github.com/git-for-windows/git/releases/tag/v$($PackageConfig.version).windows.1"
        }
        'vscode' {
            return "https://code.visualstudio.com/download"
        }
        'dotnetTools' {
            $urls = @()
            foreach ($tool in $PackageConfig.tools.PSObject.Properties) {
                $urls += "https://www.nuget.org/packages/$($tool.Value.name)/$($tool.Value.version)"
            }
            return $urls -join "`n"
        }
        default {
            return "No manual installation URL available for $PackageName"
        }
    }
}

# Create initialization script using manifest
$initScript = @'
#Requires -Version 7.0
using namespace System.Management.Automation

[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$script:ErrorActionPreference = 'Stop'
$script:InformationPreference = 'Continue'

# Initialize environment
$script:manifestPath = Join-Path $PSScriptRoot 'setup-manifest.json'
if (!(Test-Path $script:manifestPath)) {
    throw "Setup manifest not found at: $script:manifestPath"
}

# Load manifest with proper error handling
try {
    $script:manifest = Get-Content $script:manifestPath -Raw | ConvertFrom-Json

    # Convert paths to proper format
    $script:paths = @{
        ProgramFiles = $script:manifest.paths.programFiles.x64
        Packages = $script:manifest.paths.packages.root
        Setup = Join-Path $env:USERPROFILE 'Environments\PSProfile\Setup'
        Dev = Join-Path $env:USERPROFILE 'Environments\PSProfile\DevCode'
    }
} catch {
    throw "Failed to load manifest: $_"
}

# Function to write status messages with proper formatting
function Write-Status {
    param(
        [Parameter(Mandatory)]
        [string]$Message,
        [ValidateSet('Info', 'Warning', 'Error')]
        [string]$Level = 'Info'
    )

    $timestamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
    switch ($Level) {
        'Info' { Write-Information "[$timestamp] $Message" }
        'Warning' { Write-Warning "[$timestamp] $Message" }
        'Error' { Write-Error "[$timestamp] $Message" }
    }
}

# Function to safely execute commands with error handling
function Invoke-SafeCommand {
    param(
        [Parameter(Mandatory)]
        [scriptblock]$ScriptBlock,
        [string]$ErrorMessage
    )

    try {
        & $ScriptBlock
        return $true
    } catch {
        Write-Status -Level Error -Message "$ErrorMessage`: $_"
        return $false
    }
}

# Function to install packages based on type with proper variable scoping
function Install-PackageByType {
    param (
        [Parameter(Mandatory)]
        [string]$PackageName,
        [Parameter(Mandatory)]
        [object]$PackageConfig
    )

    Write-Status -Message "Installing $PackageName..." -Level Info

    try {
        $type = $PackageConfig.type
        $packageType = $script:manifest.installations.packageTypes.$type

        if (!$packageType) {
            $errorMessage = "Unknown package type: $type"
            Write-Log $errorMessage -Level Warning
            return $false
        }

        switch ($type) {
            'direct' {
                $sourcePath = $PackageConfig.path
                $targetPath = Join-Path $script:paths.ProgramFiles "$PackageName.exe"

                if (!(Test-Path $sourcePath)) {
                    Write-Log "Package not found: $PackageName at path: $sourcePath" -Level Warning
                    Write-Log "Manual installation URL: $(Get-ManualInstallationUrl -PackageName $PackageName -PackageConfig $PackageConfig)" -Level Info
                    return $false
                }

                Copy-Item -Path $sourcePath -Destination $targetPath -Force
                $env:Path = "$([System.IO.Path]::GetDirectoryName($targetPath));$env:Path"
            }
            'dotnet-tool' {
                foreach ($tool in $PackageConfig.tools.PSObject.Properties) {
                    $toolName = $tool.Value.name
                    $version = $tool.Value.version
                    $command = "$($packageType.installMethod) $($toolName) --version $($version)"

                    if (!(Invoke-Expression $command)) {
                        Write-Log "Failed to install .NET tool: $($toolName)" -Level Warning
                        return $false
                    }
                }
            }
            'self-extracting' {
                $installer = $PackageConfig.installer
                if (!(Test-Path $installer)) {
                    Write-Log "Package not found: $PackageName at path: $installer" -Level Warning
                    Write-Log "Manual installation URL: $(Get-ManualInstallationUrl -PackageName $PackageName -PackageConfig $PackageConfig)" -Level Info
                    return $false
                }

                $process = Start-Process -FilePath $installer `
                    -ArgumentList $PackageConfig.silent `
                    -Wait -PassThru -NoNewWindow

                if ($process.ExitCode -ne 0) {
                    Write-Log "Installation failed for $PackageName with exit code: $($process.ExitCode)" -Level Warning
                    return $false
                }

                if ($PackageConfig.config) {
                    foreach ($setting in $PackageConfig.config.PSObject.Properties) {
                        git config --global $setting.Name $setting.Value
                    }
                }
            }
            'archive' {
                $installer = $PackageConfig.installer
                if (!(Test-Path $installer)) {
                    Write-Log "Package not found: $PackageName at path: $installer" -Level Warning
                    Write-Log "Manual installation URL: $(Get-ManualInstallationUrl -PackageName $PackageName -PackageConfig $PackageConfig)" -Level Info
                    return $false
                }

                $destinationPath = switch ($PackageName) {
                    'powershell' { Join-Path $script:paths.ProgramFiles 'PowerShell' }
                    'vscode' { Join-Path $script:paths.ProgramFiles 'Microsoft VS Code' }
                    default { Join-Path $script:paths.ProgramFiles $PackageName }
                }

                # Create destination if it doesn't exist
                if (!(Test-Path $destinationPath)) {
                    New-Item -Path $destinationPath -ItemType Directory -Force | Out-Null
                }

                # Extract archive
                Expand-Archive -Path $installer -DestinationPath $destinationPath -Force

                # Post-extraction setup
                switch ($PackageName) {
                    'powershell' {
                        $pwshPath = Join-Path $destinationPath 'pwsh.exe'
                        if (Test-Path $pwshPath) {
                            $env:Path = "$destinationPath;$env:Path"

                            foreach ($module in $PackageConfig.modules.PSObject.Properties) {
                                $moduleConfig = $module.Value
                                $moduleParams = @{
                                    Name = $module.Name
                                    RequiredVersion = $moduleConfig.version
                                    Repository = $moduleConfig.repository
                                    Force = $true
                                }

                                & $pwshPath -NoProfile -Command {
                                    param($params)
                                    Install-Module @params
                                } -Args $moduleParams
                            }
                        } else {
                            Write-Log "PowerShell executable not found at: $pwshPath" -Level Warning
                            return $false
                        }
                    }
                    'vscode' {
                        foreach ($ext in $PackageConfig.extensions.PSObject.Properties) {
                            $extConfig = $ext.Value
                            $extId = "$($extConfig.publisher).$($extConfig.name)"
                            $vsixPath = Join-Path $script:paths.Packages "vscode\extensions\$extId-$($extConfig.version).vsix"

                            if (Test-Path $vsixPath) {
                                Write-Status -Message "Installing VSCode extension: $extId v$($extConfig.version)" -Level Info
                                & code --install-extension $vsixPath
                            } else {
                                Write-Log "VSCode extension not found: $vsixPath" -Level Warning
                            }
                        }
                    }
                }
            }
        }

        Write-Status -Message "Successfully installed $PackageName" -Level Info
        return $true
    }
    catch {
        Write-Log "Failed to install $PackageName : $_" -Level Warning
        Write-Log "Manual installation URL: $(Get-ManualInstallationUrl -PackageName $PackageName -PackageConfig $PackageConfig)" -Level Info
        return $false
    }
}

# Function to install required packages with proper error aggregation
function Install-RequiredPackages {
    Write-Status -Message "Starting package installation sequence..." -Level Info

    $failed = @()

    foreach ($package in $script:manifest.installations.sequence) {
        $config = $script:manifest.paths.packages.$package
        if (!(Install-PackageByType -PackageName $package -PackageConfig $config)) {
            $failed += $package
        }
    }

    if ($failed.Count -gt 0) {
        throw "Failed to install packages: $($failed -join ', ')"
    }

    Write-Status -Message "Package installation complete" -Level Info
}

# Main initialization sequence with proper error handling
try {
    Write-Status -Message "Starting sandbox initialization..." -Level Info

    foreach ($step in $script:manifest.scripts.initialization.order) {
        Write-Status -Message "Executing $step..." -Level Info
        & $step
    }

    Write-Status -Message "Initialization completed successfully" -Level Info

    # Open VS Code in development environment
    if (Get-Command code -ErrorAction SilentlyContinue) {
        code "$($script:paths.Dev)"
    }
} catch {
    Write-Status -Level Error -Message "Initialization failed: $_"
    exit 1
}
'@

# Save initialization script
$initScript | Out-File -FilePath $($paths.SetupPath + '\initialize.ps1') -Encoding UTF8 -Force

# If including installer/tester, copy them to scripts directory
if ($IncludeInstaller) {
    Copy-Item -Path $manifest.scripts.functions.'Install-PSProfile'.path -Destination $paths.SandboxScripts -Force
}
if ($IncludeTester) {
    Copy-Item -Path $manifest.scripts.functions.'Test-Installation'.path -Destination $paths.SandboxScripts -Force
}

Write-Log 'Sandbox environment configuration complete. To start the sandbox, run:' -Level Info
Write-Host "WindowsSandbox.exe '$($paths.SandboxRoot)\sandbox-config.wsb'"

# Display included options
if ($IncludeInstaller -or $IncludeTester -or $AutoInstall -or $AutoTest) {
    Write-Log "`nEnabled options:" -Level Info
    if ($IncludeInstaller) { Write-Log '- PSProfile installer included' -Level Info }
    if ($IncludeTester) { Write-Log '- PSProfile tester included' -Level Info }
    if ($AutoInstall) { Write-Log '- Auto-installation enabled' -Level Info }
    if ($AutoTest) { Write-Log '- Auto-testing enabled' -Level Info }
}

# Create development environment structure
Write-Log 'Setting up sandbox development environment...' -Level Info

# Create necessary directories
New-Item -Path "$($paths.DevSrcPath)" -ItemType Directory -Force
New-Item -Path "$($paths.ProfilePath)" -ItemType Directory -Force

# Copy development code to sandbox
Write-Log 'Copying development code to sandbox...' -Level Info
$srcPath = Resolve-EnvPath $manifest.environment.sandbox.dev.src
Copy-Item -Path "$srcPath\*" -Destination "$($paths.DevSrcPath)" -Recurse -Force

# Copy development profile to sandbox
Write-Log 'Copying profile to sandbox...' -Level Info
$profilePath = Resolve-EnvPath $manifest.environment.sandbox.dev.profile
Copy-Item -Path "$profilePath\*" -Destination "$($paths.ProfilePath)" -Recurse -Force

# Copy VSCode settings
Write-Log 'Copying VSCode settings...' -Level Info
$vscodeSettingsPath = Resolve-EnvPath $manifest.environment.sandbox.dev.vscode.settings
if (Test-Path $vscodeSettingsPath) {
    $vscodeDestPath = "$($paths.VSCodePath)"
    if ($vscodeSettingsPath -ne "$($paths.VSCodeSettings)") {
        New-Item -Path $vscodeDestPath -ItemType Directory -Force | Out-Null
        Copy-Item -Path $vscodeSettingsPath -Destination "$($paths.VSCodeSettings)" -Force
        Write-Log 'VSCode settings copied successfully' -Level Info
    } else {
        Write-Log 'VSCode settings source and destination are the same, skipping copy' -Level Info
    }
}
else {
    Write-Log "VSCode settings not found at: $vscodeSettingsPath" -Level Warning
}

# Main script execution
Write-Log 'Initializing offline packages...' -Level Info
Initialize-OfflinePackages -Force:$ForcePackageDownload

Write-Log "Sandbox configuration complete. Run 'WindowsSandbox.exe $($paths.SandboxRoot)\sandbox-config.wsb' to start." -Level Info
