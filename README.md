# Windows Sandbox Development Environment

A robust PowerShell-based system for creating isolated Windows Sandbox development environments with offline package
management.

## Project Overview

This project provides a robust, isolated development environment for PowerShell development and testing. It addresses
several key challenges in PowerShell development:

### Why This is Needed

1. **Isolated Testing Environment**
   - Safe execution of untested scripts
   - Prevention of system-wide changes during development
   - Isolated package and module testing
   - Protection of production environments

2. **Standardized Development Setup**
   - Consistent PowerShell Preview environment
   - Pre-configured testing frameworks (Pester)
   - Integrated development tools
   - Standardized module structure

3. **Reproducible Environment**
   - Manifest-based configuration
   - Offline package management
   - Version-controlled dependencies
   - Consistent across different machines

4. **Development Best Practices**
   - Proper testing infrastructure
   - Code organization standards
   - Error handling patterns
   - Logging and debugging capabilities

## Features

- 🔒 Isolated development environment using Windows Sandbox
- 📦 Offline-first package management
- ⚙️ JSON-based configuration manifest
- 🛠️ Automated tool installation (VSCode, PowerShell, Git)
- 📝 Flexible path mappings and permissions
- 🔄 Structured initialization sequence
- 🧪 Built-in testing support

## Prerequisites

- Windows 10/11 Pro or Enterprise with Windows Sandbox feature enabled
- PowerShell 7+ (recommended)
- Internet connection (for initial package downloads only)

## Quick Start

1. Clone this repository
2. Run the setup script:

   ```powershell
   .\setup-sandbox.ps1
   ```

### Using the Commandlet

The sandbox environment can be started using either the full commandlet name or its alias:

```powershell
# Using the full commandlet name
Start-DevSandbox

# Using the alias
devsb
```

### Command Options

The sandbox starter supports several configuration options:

```powershell
# Basic usage (uses all defaults)
devsb

# Enable PowerShell profile loading (default: disabled)
devsb -UseProfile

# Specify execution policy (default: Bypass)
devsb -ExecutionPolicy RemoteSigned

# Show verbose output
devsb -Verbose

# Specify custom script path
devsb -ScriptPath "path/to/custom/setup-sandbox.ps1"
```

#### Default Behavior

- Runs with `-NoProfile` (profiles disabled)
- Uses `Bypass` execution policy
- Looks for script in `$env:USERPROFILE\.pwsh\sandbox\setup-sandbox.ps1`

#### Available Parameters

| Parameter          | Default             | Description                                                                |
|--------------------|---------------------|----------------------------------------------------------------------------|
| `-UseProfile`      | `$false`            | Enable PowerShell profile loading                                          |
| `-ExecutionPolicy` | `"Bypass"`          | Set PowerShell execution policy (Bypass/RemoteSigned/AllSigned/Restricted) |
| `-ScriptPath`      | User's sandbox path | Custom path to setup script                                                |
| `-Verbose`         | `$false`            | Enable detailed output logging                                             |

## Configuration

The environment is configured through `setup-manifest.json`, which controls:

- 🖥️ Sandbox hardware settings (memory, vGPU)
- 🌐 Network configuration
- 📂 Path mappings and permissions
- 🔧 Installation sequences
- ⚡ Package configurations

### Manifest Structure

```json
{
    "sandboxConfig": {
        "memoryInMB": 8192,
        "vGPU": "Enable",
        "networking": "Enable"
    },
    "paths": {
        "packages": {
            "root": "C:\\Packages",
            "vscode": { ... },
            "powershell": { ... },
            "git": { ... }
        }
    }
}
```

## Sandbox Configuration (.wsb)

### Path Mapping Guidelines

1. **System Drive (C:) Mappings**
   - Use direct paths for system drive: `C:\Windows` <sup>This is a critical hook/initialiser</sup>
   - Always include a Windows test folder mapping for initialization
   ```xml
   <MappedFolder>
       <HostFolder>C:\Windows</HostFolder>
       <SandboxFolder>C:\Test</SandboxFolder>
       <ReadOnly>true</ReadOnly>
   </MappedFolder>
   ```

2. **Non-System Drive Mappings**
   - Use UNC paths for all non-system drives: `\\localhost\D$\Path`
   - Example for D: drive mapping:
   ```xml
   <MappedFolder>
       <HostFolder>\\localhost\D$\Env\PSProfile\DevCode</HostFolder>
       <SandboxFolder>C:\Users\WDAGUtilityAccount\Desktop\DevCode</SandboxFolder>
       <ReadOnly>false</ReadOnly>
   </MappedFolder>
   ```

3. **Folder Mapping Order**
   - Keep Windows test folder as first mapping
   - Order other mappings by importance/usage
   - Use consistent SandboxFolder paths (preferably under Desktop)

### Logon Command

The logon command sets up the initial PowerShell environment:
```xml
<LogonCommand>
    <Command>powershell -NoProfile -ExecutionPolicy Bypass -Command "Set-Location C:\Users\WDAGUtilityAccount\Desktop\DevCode"</Command>
</LogonCommand>
```

### Configuration Best Practices

1. **Memory and GPU Settings**
   ```xml
   <MemoryInMB>8192</MemoryInMB>
   <vGPU>Enable</vGPU>
   <Networking>Enable</Networking>
   ```

2. **Read/Write Permissions**
   - Set most mappings as read-only for security
   - Only enable write access for development directories

3. **Path Structure**
   - Use Desktop location for easy access
   - Maintain consistent path structure across configurations
   - Follow principle of least privilege for permissions

## Installation

### Installing the Sandbox Module

The sandbox environment can be installed either at the user level or system-wide, with three possible locations for
user-level installation.

#### Installation Locations

1. **Default Location** (Windows PowerShell default user modules)
   ```powershell
   Install-SandboxModule -Scope User -Location Default
   # Installs to: $HOME\Documents\PowerShell\<Version>\Modules\Start-DevSandbox
   # Example: PowerShell 7 -> \PowerShell\7\Modules\Start-DevSandbox
   ```

2. **OneDrive Location** (Synced modules)
   ```powershell
   Install-SandboxModule -Scope User -Location OneDrive
   # Automatically detects OneDrive location in this order:
   # 1. Custom path from PWSH_ONEDRIVE_PATH
   # 2. Business OneDrive location
   # 3. Personal OneDrive location
   # 4. Default OneDrive in user profile
   # 5. Fallback: D:\OneDrive\Documents
   ```

3. **Development Location** (Local development environment)
   ```powershell
   Install-SandboxModule -Scope User -Location Development
   # Default: C:\Users\<Username>\.pwsh\sandbox\Modules\Start-DevSandbox
   ```

4. **System-Wide Installation** (Requires Admin)
   ```powershell
   Start-Process pwsh -Verb RunAs
   Install-SandboxModule -Scope System
   # Installs to: $env:ProgramFiles\PowerShell\<Version>\Modules\Start-DevSandbox
   ```

#### Customizing Installation Paths

You can customize various aspects of the installation using environment variables:

```powershell
# Set custom OneDrive path
$env:PWSH_ONEDRIVE_PATH = "E:\OneDrive\Documents"  # Custom OneDrive location

# Set custom development path
$env:PWSH_DEV_PATH = "D:\Code\PowerShell"          # Custom development location

# Set custom project root
$env:PWSH_PROJECT_ROOT = "MyProjects\Sandbox"       # Custom project directory

# Set custom Setup Script
$env:PWSH_SETUP_SCRIPT = "custom-sandbox-setup.ps1" # Custom setup script name

# Install to custom location
Install-SandboxModule -Scope User -Location OneDrive
```

These environment variables can be set:
- Temporarily in your current session
- Permanently in your PowerShell profile
- System-wide through Windows Environment Variables

## Directory Structure

```folder
.
├── setup-sandbox.ps1      # Main setup script
├── setup-manifest.json    # Configuration manifest
├── README.md             # Documentation
└── packages/             # Offline packages
    ├── vscode/
    ├── powershell/
    └── git/
```

## Package Management

The environment uses an offline-first approach:

1. Packages are pre-downloaded to a local cache
2. Installation occurs from local cache in sandbox
3. Fallback to online sources if needed

### Supported Package Types

- ✅ Visual Studio Code + Extensions
- ✅ PowerShell Preview
- ✅ Git
- ✅ PowerShell Modules

## User Profiles

The sandbox environment respects Windows Sandbox user profiles:

- `ContainerAdministrator`: For elevated installations
- `ContainerUser`: Default user profile
- `Public`: Shared resources

## Security Considerations

- 🔒 Isolated environment
- 📝 Configurable read-only mappings
- 🛡️ Execution policy controls
- 🔐 Minimal system modification

## Troubleshooting

### Common Issues

1. **Package Installation Fails**
   - Verify packages in offline cache
   - Check manifest paths
   - Ensure admin privileges

2. **Path Mapping Issues**
   - Verify paths in manifest
   - Check read/write permissions
   - Ensure host paths exist

## Contributing

1. Fork the repository
2. Create a feature branch
3. Submit a pull request

## License

MIT License - See LICENSE file for details
