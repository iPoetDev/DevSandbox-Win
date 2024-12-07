# Changelog

All notable changes to this project will be documented in this file.

## [2024-01-17] Initial Development

### Added

1. Initial Setup Script Creation
   - Created base `setup-sandbox.ps1` script
   - Implemented Windows Sandbox configuration
   - Added basic file mapping functionality

2. Environment Configuration
   - Added command-line parameters for installation options
   - Implemented VSCode integration
   - Added Pester test integration

3. Path Management
   - Implemented centralized path variables
   - Added consistent Join-Path usage
   - Created organized path structure

4. Installation Verification
   - Added winget availability check
   - Implemented internet connectivity verification
   - Added package installation status checks

5. Documentation
   - Created initial README.md
   - Added inline documentation
   - Implemented help messages for parameters

### Changed

1. Path Handling Improvements
   - Moved from hardcoded paths to variables
   - Implemented environment variable usage
   - Added dynamic path resolution

2. Installation Process
   - Updated VSCode settings handling
   - Modified package installation process
   - Improved script copying mechanism

3. Logging and Output
   - Changed Write-Host to Write-Information
   - Added verbose logging options
   - Improved error messages

4. Configuration Management
   - Added Chocolatey profile support
   - Modified sandbox configuration handling
   - Updated environment variable usage

### Fixed

1. Path Issues
   - Fixed directory creation logic
   - Corrected path separators
   - Resolved environment path issues

2. Installation Process
   - Added missing package checks
   - Fixed VSCode settings copy process
   - Corrected script execution order

### Security

1. Sandbox Isolation
   - Implemented read-only mappings where appropriate
   - Added execution policy management
   - Improved folder access controls

### Dependencies

- Added Chocolatey integration
- Updated environment variable requirements
- Modified path dependencies

## [2.0.0] - 2024-01-24

### Breaking Changes

- Introduced manifest-based configuration system
- Restructured sandbox initialization process
- Changed default path mappings and permissions

### Added

- New `setup-manifest.json` configuration system
  - Centralized sandbox configuration
  - Customizable installation sequences
  - Flexible path mappings
  - Structured error messages
- Enhanced sandbox profile management
  - Proper ContainerAdministrator/ContainerUser support
  - Profile-specific configurations
  - Improved permission handling
- Structured initialization sequence
  - Ordered installation steps
  - Modular component setup
  - Dependency management
- Improved package management
  - Enhanced offline package handling
  - Version control improvements
  - Better error recovery

### Changed

- Architecture
  - Moved from hardcoded to manifest-based configuration
  - Improved separation of concerns
  - Enhanced code organization
- Sandbox Configuration
  - Configurable hardware settings (memory, vGPU)
  - Flexible networking options
  - Enhanced path mapping system
- Installation Process
  - Structured setup sequence
  - Improved error handling
  - Enhanced logging system
- Package Management
  - More robust offline handling
  - Better version management
  - Improved error recovery

### Fixed

- Path mapping issues with sandbox profiles
- Package installation sequencing
- Error handling in offline mode
- VSCode extension installation reliability
- PowerShell module import consistency

### Security

- Enhanced read-only mapping controls
- Improved execution policy management
- Better isolation configuration
- More secure package handling

### Documentation

- Updated README with manifest configuration details
- Added troubleshooting guide
- Improved installation instructions
- Enhanced security documentation

## [2024-12-07] Sandbox Configuration Improvements

### Added
- Windows test folder mapping for improved sandbox initialization
- UNC path support for non-system drive mappings
- Standardized folder mapping structure in .wsb configuration

### Fixed
- Resolved configuration issues with direct drive path mappings
- Fixed sandbox initialization errors by maintaining consistent folder mapping order
- Improved folder mapping reliability using UNC paths

### Changed
- Updated all non-system drive mappings to use UNC format (\\localhost\D$\...)
- Standardized folder mapping permissions (read-only vs read-write)
- Enhanced logon command to set initial working directory

## Technical Details

### Path Structure Changes

- Changed `$projectRoot` to use `$env:USERPROFILE`
- Updated `$sandboxEnv` to use `$env:Environments`
- Modified VSCode settings path handling

### Configuration Updates

- Added Chocolatey profile module import
- Updated sandbox configuration path handling
- Modified initialization script structure

### Installation Process

- Added winget verification
- Implemented offline installation support
- Added package repository suggestions

## [Unreleased]

### Added
- PowerShell version-aware module installation paths
- Automatic OneDrive location detection with fallback chain
- New environment variables for customization:
  - `PWSH_PROJECT_ROOT`: Custom project directory
  - `PWSH_SETUP_SCRIPT`: Custom setup script name
- Version-specific module paths (e.g., PowerShell\7\Modules for PS7)

### Changed
- Module installation paths now include PowerShell version
- Improved OneDrive path detection with multiple fallback options:
  1. Custom path from PWSH_ONEDRIVE_PATH
  2. Business OneDrive location
  3. Personal OneDrive location
  4. Default OneDrive in user profile
  5. Fallback to D:\OneDrive\Documents
- Enhanced environment variable configuration
- Updated documentation with new installation options

### Fixed
- WhatIf message implementation in Start-DevSandbox
- Module path resolution for different PowerShell versions
- Installation path handling for various scenarios

### Changed
- Renamed variables in `setup-sandbox.ps1` to avoid PowerShell reserved variable conflicts
  - Renamed `$error` to `$errorMessage` throughout the script for better PowerShell compatibility
  - Renamed `$errors` to `$validationErrors` in manifest validation function
  - Added proper `$script:` scope to preference variables
  - Improved variable naming consistency in package installation functions

### Added
- New PowerShell module `Start-DevSandbox` for easier sandbox management
  - Added `Start-DevSandbox` cmdlet with alias `devsb`
  - Implemented `-WhatIf` support for dry-run capability
  - Added proper parameter validation and error handling
  - Included module installation options for both user and system scope
  - Improved verbose output and command argument handling
  - Fixed common parameter conflicts (Verbose, Debug, etc.)

### Improved
- Module Installation and Usage
  - Added `Install-SandboxModule` function for easy deployment
  - Support for both user and system-wide installation
  - Proper module manifest and export handling
  - Enhanced error messages and installation feedback
