## Issues & Fixes

## Known Issues

### PowerShell Preview Path Configuration
- **Issue**: PATH environment variable not immediately available after installation
- **Impact**: Requires shell restart to access PowerShell Preview
- **Status**: Resolved
- **Fix**: Added immediate PATH refresh in installation script
- **Date**: 2024-12-06

### WSL Installation Restart Requirement
- **Issue**: System restart required after WSL feature enablement
- **Impact**: Installation process requires manual intervention, however, the WindowsSandbox is emphemeral and all
  contents are destroyed, so restarting is not an option
- **Status**: Known Issue
- **Options**: Can I enabled WSL for Sandbox as a preinstalled and eanbled feature in the .wsb configuration file?
- **Discard**: Add restart notification and handling in script
- **Prefered**: Pre enable WSL at WindowsSandbox.exe startup and have it preinstalled by default.
- **Date**: 2024-12-06

### Git Installation Silent Parameters
- **Issue**: Some Git installer versions ignore silent parameters
- **Impact**: May show installer UI during setup
- **Status**: Resolved
- **Fix**: Updated silent installation parameters in manifest
- **Date**: 2024-12-06

### OpenSSH Service Configuration
- **Issue**: SSH agent service not starting automatically
- **Impact**: Manual service start required
- **Status**: Resolved
- **Fix**: Added service configuration in installation script
- **Date**: 2024-12-06
