# Powershell profile for efficiency gains 💪

A PowerShell profile is a script that runs when PowerShell starts. You can use the profile as a startup script to customize your environment. You can add commands, aliases, functions, variables, modules, PowerShell drives and more. You can also add other session-specific elements to your profile so they're available in every session without having to import or re-create them.

PowerShell supports several profiles for users and host programs. However, it doesn't create the profiles for you.

### RTFM: 
[Link to Microsoft Doc - about_profiles](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_profiles?view=powershell-7.4&viewFallbackFrom=powershell-7.1)

## Profile types and locations

PowerShell supports several profile files that are scoped to users and PowerShell hosts. You can have any or all these profiles on your computer.

For example, the PowerShell console supports the following basic profile files. The profiles are listed in order that they're executed.

    All Users, All Hosts
        Windows - $PSHOME\Profile.ps1
        Linux - /opt/microsoft/powershell/7/profile.ps1
        macOS - /usr/local/microsoft/powershell/7/profile.ps1
    All Users, Current Host
        Windows - $PSHOME\Microsoft.PowerShell_profile.ps1
        Linux - /opt/microsoft/powershell/7/Microsoft.PowerShell_profile.ps1
        macOS - /usr/local/microsoft/powershell/7/Microsoft.PowerShell_profile.ps1
    Current User, All Hosts
        Windows - $HOME\Documents\PowerShell\Profile.ps1
        Linux - ~/.config/powershell/profile.ps1
        macOS - ~/.config/powershell/profile.ps1
    Current user, Current Host
        Windows - $HOME\Documents\PowerShell\Microsoft.PowerShell_profile.ps1
        Linux - ~/.config/powershell/Microsoft.PowerShell_profile.ps1
        macOS - ~/.config/powershell/Microsoft.PowerShell_profile.ps1

The profile scripts are executed in the order listed. This means that changes made in the AllUsersAllHosts profile can be overridden by any of the other profile scripts. The CurrentUserCurrentHost profile always runs last. In PowerShell Help, the CurrentUserCurrentHost profile is the profile most often referred to as your PowerShell profile.

Other programs that host PowerShell can support their own profiles. For example, Visual Studio Code (VS Code) supports the following host-specific profiles.

    All users, Current Host - $PSHOME\Microsoft.VSCode_profile.ps1
    Current user, Current Host - $HOME\Documents\PowerShell\Microsoft.VSCode_profile.ps1

The profile paths include the following variables:

    The $PSHOME variable stores the installation directory for PowerShell
    The $HOME variable stores the current user's home directory

## Quick setup (Windows 11, PowerShell 7)

This repo's profile is `Microsoft.PowerShell_profile-WIN11.ps1`. It is used by symlinking it to `$PROFILE`, so edits in the repo apply immediately.

### 1. Install PowerShell 7 and CLI tools

```powershell
winget install -e --id Microsoft.PowerShell
winget install -e --id JanDeDobbeleer.OhMyPosh   # prompt
winget install -e --id eza-community.eza          # ls / ll / la / lt
winget install -e --id sharkdp.bat                # cat
winget install -e --id ajeetdsouza.zoxide         # z (smart cd)
winget install -e --id junegunn.fzf               # fuzzy finder
winget install -e --id Neovim.Neovim              # $env:EDITOR
```

Open a new PowerShell 7 window afterwards so the new tools are on `PATH`.

### 2. Install a Nerd Font

Icons from oh-my-posh, eza and Terminal-Icons need a Nerd Font:

```powershell
oh-my-posh font install meslo
```

Then set it in Windows Terminal: **Settings > PowerShell > Appearance > Font face > MesloLGM Nerd Font**.

### 3. Install PowerShell modules

```powershell
Install-Module PSReadLine -Scope CurrentUser -Force   # needs 2.2+ for ListView predictions
Install-Module Terminal-Icons -Scope CurrentUser
Install-Module PSFzf -Scope CurrentUser
```

### 4. Clone the repo and link the profile

The oh-my-posh theme path is hard-coded to `$HOME\Documents\GitHub\powershellProfile`, so clone it there:

```powershell
git clone https://github.com/mbonne/powershellProfile "$HOME\Documents\GitHub\powershellProfile"
```

From an **admin** PowerShell (or with Developer Mode on), back up any existing profile and create the symlink:

```powershell
if (Test-Path $PROFILE) { Move-Item $PROFILE "$PROFILE.bak" }
New-Item -ItemType SymbolicLink -Path $PROFILE -Target "$HOME\Documents\GitHub\powershellProfile\Microsoft.PowerShell_profile-WIN11.ps1" -Force
```

Optional: clone custom modules, which are auto-imported if present:

```powershell
git clone https://github.com/mbonne/pwsh "$HOME\Documents\GitHub\pwsh"
```

### 5. Reload

```powershell
. $PROFILE
```

## What the profile does

| Feature | Details |
|---|---|
| PSReadLine | Emacs keys (`Ctrl+a`/`Ctrl+e`), OneDark colours, history + plugin predictions in ListView, no duplicate history, no bell |
| History filter | Lines containing `password`, `asplaintext`, `token`, `key` or `secret` are not saved to history |
| Prompt | oh-my-posh with `negligible-noTime.omp.json` (more themes in `themes/`) |
| Startup info | Date, free/total RAM, C: disk used/free, uptime |
| `ls` `ll` `la` `lt` | eza with icons (`ll` adds git status, `lt` shows a tree) |
| `cat` | bat |
| `z` | zoxide |
| `Ctrl+t` / `Ctrl+r` | PSFzf file picker / history search |
| `..` `...` `....` | Go up 1, 2 or 3 directories |
| `source` | Reload the profile |
| `genpass` | Generate a password |
| `ln <link> <target>` | Create a symlink (admin) |
| `wgs` / `wgi` / `wg` | winget search / install / alias |
| Terminal-Icons | Loaded on first `Get-ChildItem` to speed up startup |
| `$p` | Shortcut to `$PROFILE`; `$env:EDITOR` is `nvim` |

## Troubleshooting

- **`eza`/`bat`/`zoxide`/`oh-my-posh` not recognized**: install it (step 1) and open a new window.
- **`Import-Module PSFzf` fails**: run step 3.
- **Boxes instead of icons**: set a Nerd Font in your terminal (step 2).
- **Prompt theme not found**: the repo is not at `$HOME\Documents\GitHub\powershellProfile`; move it or edit the `oh-my-posh --config` path.
- **Scripts disabled**: `Set-ExecutionPolicy -Scope CurrentUser RemoteSigned`.

## Reference: managing profiles

### Check if you have a Profile

```powershell
$PROFILE | Get-Member -Type NoteProperty
```

If the response has values for all four values, especially CurrentUserCurrentHost, you have a profile. If not you can create one by using the following command:

```powershell
if (!(Test-Path -Path $PROFILE)) { New-Item -ItemType File -Path $PROFILE -Force }
```
You should now have a profile for the current user in the current PowerShell host application.

## How to edit a profile

You can open PowerShell profile in any text editor.

```powershell
notepad $PROFILE
## or vscode
code $PROFILE
```

To open other profiles, specify the profile name. For example, to open the profile for all the users of all the host applications, type:
```PowerShell
code $PROFILE.AllUsersAllHosts
```

To apply the changes, save the changes, and restart PowerShell or reload the script
```powershell
. $PROFILE
```

## Link the profile to github file in different location to default path
[Create symlink in windows](https://woshub.com/create-symlink-windows/)
```powershell
New-Item -ItemType SymbolicLink -Path "$HOME\Documents\PowerShell\Microsoft.PowerShell_profile.ps1" -Target "$HOME\Documents\GitHub\YourRepo\Microsoft.PowerShell_profile.ps1"
```
[Create symlink in macOS and Linux](https://www.howtogeek.com/297721/how-to-create-and-use-symbolic-links-aka-symlinks-on-a-mac/)
```bash
ln -s "~/.config/powershell/Microsoft.PowerShell_profile.ps1" "~/Documents/GitHub/YourRepo/profile.ps1"
```
