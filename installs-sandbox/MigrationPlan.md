## Migration Plan

> Key
>> ✅ Implemented
>> ⚠️ In Progress
>> ❌ Not Implemented

## Thread Activity Analysis

The thread developed installation scripts for multiple development tools,
- progressing from PowerShell Preview to GitHub CLI.
- Each implementation followed a similar pattern but with varying degrees of manifest integration.

## Current Implementation State

**Implemented Components**:
- ✅ PowerShell Preview installation and testing
- ✅ Git client setup with manifest
- ✅ OpenSSH Windows feature enablement
- ✅ WSL2 installation
- ✅ Bitwarden desktop and CLI
- ✅ GPG for Windows
- ✅ GitHub CLI

## Manifest Integration Analysis

### Current Issues
- ✅ Individual installation scripts are not properly reading from setup-manifest.json
- ✅ ~~Package paths are hardcoded rather than pulled from package-manifest.json~~
- ✅ ~~Installation sequences defined in setup-manifest.json are not being followed~~


## Recommendations

1. Create a core manifest reader module:
2. Standardize installation functions:
3. Implement proper testing integration:
```powershell
function Test-Package {
    param(
        [string]$PackageId
    )

    $config = Initialize-Installation -PackageId $PackageId
    # Run appropriate test based on package type
}
```

## Migrate v2

This is the latests migrtaion plan

Yes, all installation scripts need to be adjusted. Here's the analysis:

## Required Changes

### Required Checks

- Update the installation scripts
- Change the install manifests
- Update the test scripts
- Check the client's setup manifect for general package management
- Update the Setup-Packages.psm1 module
- Check the sandbox-manifest.json file, and alignment with install manifests
- Update any changes to setup-sandbox.ps1

### ✅ 1. PowerShell Preview Installation
- ✅ Updates the installer script
- ✅ Installer script integrated with its own install manifest
- ✅ Installer script integrated with init manifest
- ✅ Already defined in client-setup-manifest.json as "self-extracting" type
- ✅ Has module installation configuration for Pster, PlatyPUs, and PSScriptAnalyzer

### ⚠️ 2. Git Installation
- ✅ Updates the installer script
- ✅ Installer script integrated with its own install manifest
- ✅ Installer script integrated with package manifest
- ✅ Already defined in setup-manifest.json as "self-extracting" type
- ✅ Has configuration settings for core.autocrlf and init.defaultBranch
- ⚠️ Needs to use PackageInstallation class from Setup-Packages.psm1

### ⚠️  3. SSH Installation
- ✅ Updates the installer script
- ✅ Installer script integrated with its own install manifest
- ✅ Not defined in current manifests
- ⚠️ Requires new installation type handler in Setup-Packages.psm1
- ⚠️ Needs to be added to package-manifest.json as "windows-feature" type
- ✅ Needs to be added to setup-manifest.json as Windows Feature type


### ✅ 4. WSL Installation
- ✅ Updates the installer scripy
- ✅ Installer script integrated with its own install manifest
- ✅ Not defined in current manifests
- ⚠️ Requires new installation type handler in Setup-Packages.psm1
- ⚠️ Needs to be added to package-manifest.json as "windows-feature" type
- ✅ Needs to be added to setup-manifest.json as Windows Feature type

### ✅ 5. Bitwarden Installation
- ✅ Updates the installer Script
- ✅ Installer script integrated with its own install manifest
- ⚠️ Not defined in current manifests
- ⚠️ Needs to be added to package-manifest.json for downloading
- ✅ Needs to be added to setup-manifest.json for initialisation configuration

### 6. GPG Installation
- ✅ Updates the installer scripy
- ✅ Installer script integrated with its own install manifest
- ⚠️ Not defined in current manifests
- ⚠️ Needs to be added to package-manifest.json for downloading
- ✅ Needs to be added to setup-manifest.json for initialisation configuration

### 7. GitHub CLI Installation
- ✅ Updates the installer script
- ✅ Installer script integrated with its own install manifest
- ⚠️ Not defined in current manifests
- ⚠️ Needs to be added to package-manifest.json for downloading
- ✅ Needs to be added to setup-manifest.json for initialisation configuration


### Missing Elements

1. **Package Management**:

- IF NEEDED: LOW PRIORITY: No integration with the offline package manager system[1]
- IF NEEDED: LOW PRIROITY: Missing validation against package-manifest.json versions[2] -> {{ PROMPT: {{  Doesn't setup-sandbox.ps1 handle this?
  }} }}

2. **Configuration Flow**:

- CHECK IF: Installation scripts don't follow the defined installation sequence[4]
- CHECK IF: Missing error handling patterns defined in setup-manifest.json[4]

### Planned Changes

1. **Path Management**:
- ✅ ~~Replace hardcoded paths with manifest references~~
- ✅ ~~Implement path resolution from setup-manifest.json~~

2. **Version Control**:
- ❌ Add version validation against package-manifest.json
- ❌ Implement version checking in test scripts

3. **Error Handling**:
- ❌ Standardize error messages using manifest templates
- ❌ Implement proper logging as defined in implementation plan[3]

4. **Configuration Management**:
- ❌ Create unified configuration reader
- ❌ Implement manifest-driven installation options

## Implementation Requirements

### Verify

2. Each installation script needs to:
- Accept [PackageInstallation] parameter
- Use configuration from manifest
- Follow standard error handling pattern
- Integrate with sandbox environment paths

3. Update setup-manifest.json to include all package configurations:
- change name from setup-manifest oto either init-manifest.json or sandbox-manifest.json
- Installation sequences
- Package-specific configurations
- Dependencies between packages
- Validation requirements

3. Update the host machine's Get-OfflinePackages.ps1 and package-manifest.json to include all installer download
   configurations:

> 1. First, a implementation note: Get-OfflinePackages.ps1 and package-manifest.json are intended to be run separately from
> setup-sandbox.ps1.
> 2. Get-OfflinePackages.ps1 should be run first to download all installer files to a source packages directory
> 3. package-manifest.json should be used to read all installer configurations from the source packages directory
> 4. Once the packages are downloaded, then then setup-sandbox.ps1 should be run to install all packages to client
>    machine/virtual machine
> 5. However, we need to backverify that
> a) setup-menifest.json's packages is on partity with package-manifest.json's
> b) and that the client copying to C:/Paclages is consistent with the packages in on host machine
> 6. And that individual install-manifests are on partity with their installer in either C:/Packages or host's machine
>    package-manifest.json


- Packages inventory aligns with init-manifest.json
- Package-specific configurations
- Dependencies between packages
- Validation requirements


This standardization ensures consistent installation behavior and proper integration with the sandbox environment[2][4].

Citations: [1]
https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/388331/a25ecf9f-8a9e-4800-a324-57a3e2241284/setup-sandbox.ps1
[2]
https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/388331/43bc116c-169e-4a13-ad66-2898b64e8417/setup-manifest.json
[3] https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/388331/29555be1-0b3d-4a30-b891-04891b7b7a5c/README.md[4]
https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/388331/b9a8a8e9-6072-4ff2-9573-41fa615edfd0/package-manifest.json[5]
https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/388331/cd0b1804-4453-422a-9a7b-b1552370f5a0/ImplementationPlan.md[6]
