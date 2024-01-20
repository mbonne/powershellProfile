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

## Check if you have a Profile

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
