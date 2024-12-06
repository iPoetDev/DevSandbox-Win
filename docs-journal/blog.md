# Building a PowerShell Sandbox Environment in 24 Hours with Windsurf

## The Challenge: From Idea to Implementation

As an intermediate PowerShell developer, I recently tackled an interesting challenge: creating a sandboxed development environment that would let me test PowerShell scripts safely without risking my main system. Here's my 24-hour journey using Windsurf, and how it transformed what could have been a week-long project into a day's work.

### 🔍 The Challenge
The task seemed straightforward but had layers of complexity:
- Create an isolated testing environment
- Mirror my production PowerShell setup
- Support offline development
- Make it easily reproducible
- Keep it maintainable long-term

### 🎮 Leveraging Windows Sandbox
One of the smartest decisions was using Windows' built-in sandbox capability. Getting started was surprisingly simple:

```powershell
# Enable Windows Sandbox feature
Enable-WindowsOptionalFeature -FeatureName "Containers-DisposableClientVM" -Online
```

This gave us immediate access to:
- 🔒 Isolated Windows environment
- 🔄 Clean state on every launch
- 📦 Integration with host system
- ⚡ Native performance
- 🛡️ Secure by design

The beauty of Windows Sandbox (`WindowsSandbox.exe`) is that it's:
- Built into Windows 10/11 Pro and Enterprise
- Lightweight and quick to start
- Perfect for testing potentially risky code
- Automatically cleaned up after use

### 🤔 Initial Ideation with Perplexity AI
Before diving into development, I started with five key questions on Perplexity AI to shape my understanding:

1. "How do I setup a test environment for PowerShell?"
   - Led to exploring isolated environment options
   - Introduced Windows Sandbox concepts

2. "What about a preview environment for PowerShell?"
   - Highlighted need for version management
   - Suggested maintaining multiple PowerShell versions

3. "How do I create a sandbox environment for PowerShell testing?"
   - Revealed Windows Sandbox potential
   - Pointed to containerization approaches

4. "How do I run PowerShell in temporary environment?"
   - Introduced disposable environment concepts
   - Suggested state management approaches

5. "How do I execute my module in the Disposable Client?"
   - Focused on module portability
   - Highlighted package management needs

These questions helped shape our core requirements:
- ✅ Isolated testing environment
- ✅ Version management
- ✅ Package management
- ✅ State persistence options
- ✅ Module portability

## 🌅 Morning: Getting Started

### The Initial Problem
Every PowerShell developer knows the anxiety of testing new scripts. One wrong command and... well, let's not go there. I needed a solution that would:
- Isolate potentially risky code
- Mirror my actual PowerShell environment
- Work offline (because demos during network outages are fun, right?)

### Enter Windsurf
I'd heard about Windsurf, the new agentic IDE, but hadn't used it extensively. Its AI Flow paradigm sounded promising, so I decided to give it a shot. Little did I know it would become my pair programming buddy for the next 24 hours!

## 🌞 Midday: The Building Blocks

### Foundation First
Windsurf's Cascade AI immediately grasped what I was trying to do. When I explained my need for a sandboxed environment, it didn't just throw code at me – it helped design the architecture:

1. A core PowerShell module
2. Flexible installation options
3. Offline package management

What impressed me was how it understood the Windows Sandbox feature's potential and suggested using it as our foundation.

### The Aha! Moment
The breakthrough came when Cascade suggested using environment variables for configuration. Instead of hardcoding paths (my usual rookie mistake), it helped implement a flexible system:
```powershell
$env:PWSH_ONEDRIVE_PATH    # For synced modules
$env:PWSH_DEV_PATH        # For development
$env:PWSH_PROJECT_ROOT    # For project structure
```

## 🌇 Afternoon: Mastering Offline Package Management

### 🤔 The Problem I Needed to Solve
Ever tried to set up a development environment when the internet is down? Or worse, during a live demo? Yeah, been there! That's why I created an offline package management system that works like a mini "app store" on your computer.

### 💻 For the Tech-Savvy Reader
I built a structured package management system at `D:\Env\packages` that:
- Maintains multiple versions of development tools (VS Code, PowerShell, Git)
- Uses symbolic links for "latest" versions
- Manages everything through a JSON manifest
- Supports silent installations with custom parameters

Here's a peek at how it's organized:
```
D:\Env\packages\
├── vscode\
│   ├── 1.80.0\        # Specific version
│   └── latest\        # Points to latest version
├── powershell\
└── git\
```

### 🏪 For the Non-Technical Reader
Think of it like having a backup grocery store in your garage:
- All your favorite ingredients are there (programs you need)
- Everything is organized by type and date (versions)
- There's a master list of what's available (the manifest)
- You can cook even if the stores are closed (offline installation)

### ⭐ Why This Matters
1. **Reliability**: No more "but it works on my machine!" moments
2. **Speed**: Install everything in minutes, not hours
3. **Consistency**: Everyone gets the same setup, every time
4. **Peace of Mind**: Internet down? No problem!


## 🌙 Evening: Putting It All Together

### The Final Push
As the day wound down, we added:
- WhatIf support (because who doesn't love a dry run?)
- Comprehensive error handling
- A beautiful README (yes, documentation matters!)

### The Result
The final product is something I'm genuinely proud of:
- 🔒 Isolated testing environment
- 📦 Offline package management
- ⚙️ Flexible configuration
- 🛠️ Easy installation

## 🎓 Lessons Learned

### The Power of AI Pair Programming
Windsurf's Cascade AI wasn't just a code generator – it was a mentor. It:
- Suggested best practices I didn't know about
- Caught potential issues before they became problems
- Helped with documentation as we went along

### The Win of Configuration as Data
One of the biggest wins was separating configuration from code using a JSON manifest. Here's why it made such a difference:

- 🔄 **Easier Updates**: Changing configuration doesn't require modifying code
- 🔍 **Better Validation**: JSON schema validation catches errors before runtime
- 📝 **Self-Documenting**: The manifest structure clearly shows what can be configured
- 🔧 **Runtime Flexibility**: Configuration can be modified without redeploying code

Example of our manifest approach:
```json
{
  "sandbox": {
    "packages": ["vscode", "git"],
    "paths": {
      "modules": "${env:PWSH_DEV_PATH}",
      "offline": "D:/Env/packages"
    }
  }
}
```
vs. the old way of hardcoding in PowerShell:
```powershell
$packages = @('vscode', 'git')
$modulePath = $env:PWSH_DEV_PATH
$offlinePath = 'D:/Env/packages'
```

The JSON approach proved invaluable when testing different configurations and sharing setups between team members.

### The Joy of Modern Tools
Windows Sandbox + PowerShell + Windsurf is a powerful combination. Each tool brought something to the table:
- Windows Sandbox: Isolation and safety
- PowerShell: Flexibility and power
- Windsurf: Guidance and acceleration

## 🎯 For the Non-Technical Folks
Imagine wanting to try a new recipe but worrying about messing up your kitchen. This project is like having a magical second kitchen where you can experiment freely, knowing your main kitchen stays clean. Plus, this kitchen comes with all ingredients pre-stocked!

## 🚀 What's Next?
While the current version does everything I need, there's always room for improvement:
- Cross-platform support (Linux, here we come!)
- More package management options
- Automatic updates

## 🤔 Final Thoughts
What amazes me most isn't just what we built, but how we built it. Windsurf turned what could have been a complex, multi-week project into a focused, productive day of development. It's not about replacing developers – it's about amplifying what we can do.

For those interested in trying it out, the project is available at my GitHub. Feel free to fork, contribute, or just take it for a spin!

*Remember: The best code is the code that helps others. Happy sandboxing!* 🎮
