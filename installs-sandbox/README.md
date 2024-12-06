## README.md

# Windows Client Development Environment Setup Scripts

A collection of automated installation and verification scripts for setting up a development environment in Windows,
specifically designed for sandboxed environments.

## Features

- Automated installation scripts for essential development tools:
  - PowerShell Preview (7.4.0)
  - Git for Windows (2.43.0)
  - Windows OpenSSH Client
  - Windows Subsystem for Linux (WSL2)
  - Bitwarden Desktop and CLI
  - GitHub CLI
  - GPG for Windows

## Installation Scripts

Each tool includes:
- Silent installation support
- Verification testing
- Configuration manifests
- Path management
- Integration checks

## Usage

```powershell
# Install PowerShell Preview
Install-PowerShellPreview

# Install Git
Install-GitClient

# Enable OpenSSH
Enable-WindowsOpenSSH

# Enable WSL
Enable-WindowsWSL

# Install Bitwarden
Install-BitwardenClient

# Install GPG
Install-GPGClient

# Install GitHub CLI
Install-GitHubCLI
```

## Verification

Each component includes a test function:
```powershell
Test-PowerShellInstallation
Test-GitInstallation
Test-OpenSSHInstallation
Test-WSLInstallation
Test-BitwardenInstallation
Test-GPGInstallation
Test-GitHubCLIInstallation
```

Citations: [1]
https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/388331/29555be1-0b3d-4a30-b891-04891b7b7a5c/README.md [2]
https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/388331/b9a8a8e9-6072-4ff2-9573-41fa615edfd0/package-manifest.json
[3]
https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/388331/cd0b1804-4453-422a-9a7b-b1552370f5a0/ImplementationPlan.md
[4]
https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/388331/3201646f-1601-4b85-b084-46070e57b513/setup-manifest.json
