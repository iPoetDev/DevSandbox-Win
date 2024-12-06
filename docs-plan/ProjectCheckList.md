<!-- markdownlint-disable MD012 MD022 MD024 MD029 MD031 MD032 MD034  -->

# Project Checklist

> Key Per checklist text item
>> - [x] ✅ DONE
>> - [*] ⚠️ IN PROGRESS
>> - [ ] ℹ️ TODO
>> - [ ] ❌ BLOCKED

## Preparation Phase

- [x] ✅ DONE: 1. Create a dedicated folder structure on host machine:
   ```powershell
   New-Item -Path "D:/Env/WindowsSandbox" -ItemType Directory
   New-Item -Path "D:/Env/PSProfile/packages" -ItemType Directory
   New-Item -Path "D:/Env/PSProfile/Setup" -ItemType Directory
   New-Item -Path "D:/Env/PSProfile/DevCode" -ItemType Directory
   New-Item -Path "D:/Env/PSProfile/ProfileRef" -ItemType Directory[1]
   ```

- [x] ✅ DONE 2. Enable Windows Sandbox feature:
   ```powershell
   Enable-WindowsOptionalFeature -Online -FeatureName "Containers-DisposableClientVM" -All[2]
   ```

## Test Environment Setup
- [x] ✅ DONE 3. Create sandbox configuration file (sandbox.wsb):
   ```xml
   <Configuration>
     <MappedFolders>
       <MappedFolder>
         <HostFolder>C:/WindowsSandbox</HostFolder>
         <SandboxFolder>C:/Sandbox</SandboxFolder>
         <ReadOnly>false</ReadOnly>
       </MappedFolder>
     </MappedFolders>
     <LogonCommand>
       <Command>powershell -ExecutionPolicy Bypass -File C:/Sandbox/Scripts/setup.ps1</Command>
     </LogonCommand>
   </Configuration>
   ```

- [x] ✅ DONE 4. Create setup script (setup.ps1) to configure sandbox environment:
   ```powershell
   # Set execution policy
   Set-ExecutionPolicy RemoteSigned -Force

   # Create working directories
   New-Item -Path "C:/Work" -ItemType Directory
   New-Item -Path "C:/Tests" -ItemType Directory[6]
   ```

## Module Testing Structure
- [x] ✅ DONE 5. Create Pester test structure on host machine:
   ```powershell
   New-Item -Path "C:/Users/Charles/.pwsh/Modules/PSProfile/Tests/ModuleName.Tests.ps1"
   New-Item -Path "C:/WindowsSandbox/Modules/Unit.Tests.ps1"
   New-Item -Path "C:/WindowsSandbox/Modules/Integration.Tests.ps1"[7]
   ```

- [x] ✅ DONE 6. Create TUI module template at C:/Users/Charles/.pwsh/Modules/PSProfile:
   ```powershell
   Import-Module PSProfile.Core, PSProfile.Features, PSProfile.UI
   $core = (Get-Module PSProfile.Core -List).ModuleBase
   $features = (Get-Module PSProfile.Features -List).ModuleBase
   $ui = (Get-Module PSProfile.UI -List).ModuleBase
   #Add-Type -Path (Join-Path $core Terminal.Gui.dll)[3]
   #Add-Type -Path (Join-Path $ui Terminal.Gui.dll)[3]
   #Add-Type -Path (Join-Path $module Terminal.Gui.dll)[3]
   ```

## Test Implementation
- [x] ✅ DONE  7. Create base test file structure at C:\Users\Charles\.pwsh\Modules\PSProfile\Tests:
   ```powershell
   Describe "Module Tests" {
       Context "Module Structure" {
           It "Module manifest should exist" {
               Test-Path "$here/$moduleName.psd1" | Should -Be $true
           }
       }
   }[8]
   ```

- [x] ✅ DONE 8. Implement TUI test cases:
   ```powershell
   Describe "TUI Tests" {
       Context "Menu Structure" {
           It "Should have main menu items" {
               $mainMenu.Items.Count | Should -BeGreaterThan 0
           }
       }
   }
   ```

## Sandbox Configuration
- [*] ⚠️ IN PROGRESS 9. Create PowerShell Preview installation script
- [ ] ℹ️ TODO 10. Configure Git installation script
- [ ] ℹ️ TODO 11. Set up SSH configuration script
- [x] ✅ DONE 12. Create offline package manager configuration
- [x] ✅ DONE 13. Download required installers to `D:/Env/PSProfile/packages`
- [*] ⚠️ IN PROGRESS 14. Create module deployment script
- [ ] ℹ️ TODO 15. Configure test environment variables
- [ ] ℹ️ TODO 16. Set up mock data for testing
- [ ] ℹ️ TODO 17. Create cleanup scripts without shuting WindowsSandbox
- [ ] ℹ️ TODO 18. Cleanup by shuting WindowsSandbox

## Test Execution Setup
- [ ] ℹ️ TODO 19. Create test runner script
- [ ] ℹ️ TODO 20. Configure test reporting
- [ ] ℹ️ TODO 21. Set up code coverage tracking
- [*] ⚠️ IN PROGRESS 22. Implement error logging for sandbox environment
- [ ] ℹ️ TODO 23. Implement error logging for tests
- [ ] ℹ️ TODO 24. Implement error logging for modules
- [ ] ℹ️ TODO 25. Create test result collection mechanism
- [ ] ℹ️ TODO 26. Set up automated test execution

## Integration Setup
Integration Tests here: C:\Users\Charles\.pwsh\Modules\PSProfile\Tests\Integration

- [*] ⚠️ IN PROGRESS 26. Configure Git integration tests
- [*] ⚠️ IN PROGRESS 27. Set up SSH connection tests
- [ ] ℹ️ TODO 28. Create mock repository for Git testing or use existing one
- [*] ⚠️ IN PROGRESS 29. Configure TUI-specific test scenarios
- [*] ⚠️ IN PROGRESS 30. Implement keyboard interaction tests
- [*] ⚠️ IN PROGRESS31. Set up menu navigation tests

## Final Configuration
- [ ] ℹ️ TODO 31. Create master test execution script
- [ ] ℹ️ TODO 32. Set up test result aggregation
- [ ] ℹ️ TODO 33. Configure cleanup procedures
- [ ] ℹ️ TODO 34. Implement sandbox reset functionality (Inherent in Windows Sandbox being closed)
- [*] ⚠️ IN PROGRESS 35. Create test documentation generation

## Execution
- [ ] ℹ️ TODO 36. Run sandbox environment:

   ```powershell
   devsb # Start-DevSandbox commandlet
   ```


   ```powershell
   setup-sandbox.ps1
   ```

- [ ] ℹ️ TODO 37. Execute test suite:
   ```powershell
   Invoke-Pester -Path "C:/Tests" -PassThru[7]
   ```

- [ ] ℹ️ TODO 38. Generate test reports:
   ```powershell
   Invoke-Pester -Path "C:/Tests" -OutputFile "TestResults.xml" -OutputFormat NUnitXml[5]
   ```



Citations: [1] https://powershellisfun.com/2023/04/03/using-run-in-sandbox-for-testing-scripts-and-intune-packages/ [2]
https://learn.microsoft.com/sk-sk/windows/security/application-security/application-isolation/windows-sandbox/windows-sandbox-overview
[3] https://blog.ironmansoftware.com/tui-powershell/ [4]
https://www.linkedin.com/advice/0/what-most-effective-strategies-testing-powershell-kdyyf [5]
https://endjin.com/blog/2023/03/creating-pester-unit-tests-in-powershell [6]
https://jdhitsolutions.com/blog/powershell/7621/doing-more-with-windows-sandbox/ [7]
https://docs.github.com/en/actions/use-cases-and-examples/building-and-testing/building-and-testing-powershell [8]
https://www.red-gate.com/simple-talk/sysadmin/powershell/testing-powershell-modules-with-pester/ [9]
https://powershellisfun.com/2024/08/02/creating-a-development-windows-sandbox-using-powershell-and-winget/
