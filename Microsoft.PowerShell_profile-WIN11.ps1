## https://stackoverflow.com/questions/24914589/how-to-create-permanent-powershell-aliases
## https://www.howtogeek.com/50236/customizing-your-powershell-profile/
## https://thesmashy.medium.com/helpful-functions-for-your-powershell-profile-9fece679f4d6
## create symbolic links windows: https://woshub.com/create-symlink-windows/

## This profile is setup with following sections

## Path additions for cli tools
## https://stackoverflow.com/questions/714877/setting-windows-powershell-environment-variables

## -> https://github.com/PowerShell/PSReadLine
## example profile: https://github.com/PowerShell/PSReadLine/blob/master/PSReadLine/SamplePSReadLineProfile.ps1

#Import-Module PSReadLine

## Add Fish like terminal behaviour and colouring among other things.
## To show the various commands.
## Get-PSReadLineKeyHandler
## and
## Get-PSReadLineOption
## to change options use:
## Set-PsReadLineOption -PredictionSource History

#https://megamorf.gitlab.io/cheat-sheets/powershell-psreadline/
#Prevent leaking passwords or other secrets exluding from history - TODO: confirm it actually does this.
Set-PSReadLineOption -AddToHistoryHandler {
    param([string]$line)

    $sensitive = "password|asplaintext|token|key|secret"
    return ($line -notmatch $sensitive)
}


$PSReadLineOptions = @{
    EditMode = "Emacs" #Navigate like linux shell - e.g. Ctrl+a and Ctrl+e
    HistoryNoDuplicates = $true
    BellStyle = "None"
    Colors = @{
        #Based on OneDark Theme
        "Command" = "#56B6C2" #cyan
        "String" = "#98C379" #green
        "Number" = "#D19A66" #orange
        "Variable" = "#E06C75" #red
        "Keyword" = "#C678DD" #purple
        "Default" = "#D19A66" #orange
        "Type" = "#61AFEF" #blue
        "Member" = "#61AFEF" #blue
    }
}
Set-PSReadLineOption @PSReadLineOptions

# Modify ls / Get-ChildItem \ dir to show directory in bold instead of blue background colour.
#https://superuser.com/questions/1756130/change-color-of-powershell-7-get-childitem-result
$PSStyle.FileInfo.Directory = "`e[1m" # Note the double quotes!

# Searching for commands with up/down arrow is really handy.  The
# option "moves to end" is useful if you want the cursor at the end
# of the line while cycling through history like it does w/o searching,
# without that option, the cursor will remain at the position it was
# when you used up arrow, which can be useful if you forget the exact
# string you started the search on.
#Set-PSReadLineOption -HistorySearchCursorMovesToEnd
Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward
Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward

#Exit the shell / close
Set-PSReadLineKeyHandler -Key Ctrl+d -Function DeleteCharOrExit


## Functions to do more advanced things

## Alias to shorten commands
$p = "$PROFILE"

# $myBin = "$HOME\.bin"
# If(!(test-path -PathType container $myBin)){
#     New-Item -ItemType Directory -Path $myBin
# }
# ## Adding a bin folder
# $env:PATH += ";$myBin"

## Adding iPerf3 to path - https://iperf.fr/iperf-download.php
$env:PATH += ";C:\Program Files\iperf3\iperf-3.1.3-win64"

# Path to Terminal App settings. Can be used when adding custom Colours etc.
# e.g. code $terminalSettings
$terminalSettings = "$HOME\AppData\Local\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"

# Importing custom powershell modules. these can be any collection of ".psm1" files
# https://learn.microsoft.com/en-us/powershell/scripting/developer/module/how-to-write-a-powershell-script-module?view=powershell-7.4
Get-ChildItem "$HOME\Documents\GitHub\pwsh\Modules\" -recurse | Where-Object {$_.extension -eq ".psm1"} | ForEach-Object {Import-Module $_.FullName}

Write-Host -Verbose

###SETUP THE THEME https://powers-hell.com/2020/04/05/replicate-your-favorite-vscode-theme-in-windows-terminal/
#Install-Module -Name MSTerminalSettings -Scope CurrentUser


###


# Function example
# function Do-ActualThing {
#     # do actual thing
# }

# reload profile like terminal - but remember you can also type '& $p' or '. $p' etc.
function source {
    & $p
}

Function genpass {
-join(48..57+65..90+97..122|ForEach-Object{[char]$_}|Get-Random -C 20)
}



# Adding functions to use -ForegroundColor flag with Write-Output as well as Write-Host
# https://stackoverflow.com/questions/4647756/is-there-a-way-to-specify-a-font-color-when-using-write-output
function Green
{
    process { Write-Host $_ -ForegroundColor Green }
}

function Red
{
    process { Write-Host $_ -ForegroundColor Red }
}

# Make a symbolic link - Needs to be run from Admin shell
# This is handy if you want to add github repo scripts to the custom bin folder.
function ln ([string]$symlink,[string]$target) {
    if (($symlink) -or ($target)) {
        Write-Output ">>> New-Item -ItemType SymbolicLink -Path $symlink -Target $target" | Green
        New-Item -ItemType SymbolicLink -Path $symlink -Target $target
    } else {
        Write-Output ">>> You need to specify both Symbolic Link file name AND the original target file" | Red
    }

}

#Move an item like mv in bash
#https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.management/move-item?view=powershell-7.4
function mv([string]$targetObj,[string]$destinationObj) {
    Write-Host ">>> Move-Item -Path $targetObj -Destination $destinationObj -Confirm"
    Move-Item -Path $targetObj -Destination $destinationObj -Confirm    
}


## Poormans Grep
# look for string in text
## Example: grep  <string
# look for string from pipe
## Example: Get-ChildItem *.txt | grep "error"
function grep($regex, $dir) {
        if ( $dir ) {
                Get-ChildItem $dir | select-string $regex
                return
        }
        $input | select-string $regex
}


function ip {
    get-netipaddress -AddressFamily IPv4 | Where-Object PrefixOrigin -ne "WellKnown" | Select-Object InterfaceAlias, IPAddress, PrefixLength, PrefixOrigin
}


## DNS checking commands - start
function dig([string]$hostAddress) {
    Write-Host ">>> Resolve-DnsName -Name $hostAddress"
    Resolve-DnsName -Name "$hostAddress"
}

function diga([string]$hostAddress) {
    Write-Host ">>> Resolve-DnsName -Type A -Name $hostAddress"
    $digAnswer = Resolve-DnsName -Type A -Name "$hostAddress"
    Write-Output ($digAnswer).IPAddress | Green
    $digAnswer | Format-Table -AutoSize -Property Name,Type,TTL,Section,IPAddress,Strings
}

function digc([string]$hostAddress) {
    Write-Host ">>> Resolve-DnsName -Type CNAME -Name $hostAddress"
    $digAnswer = Resolve-DnsName -Type CNAME -Name "$hostAddress"
    Write-Output ($digAnswer).IPAddress | Green
    $digAnswer | Format-Table -AutoSize -Property Name,Type,TTL,Section,NameHost,Strings
}

function digm([string]$hostAddress) {
    Write-Host ">>> Resolve-DnsName -Type MX -Name $hostAddress"
    Resolve-DnsName -Type MX -Name "$hostAddress" | Format-Table -AutoSize -Property Name,Type,TTL,Section,NameExchange,Preference,Strings
}

function digt([string]$hostAddress) {
    Write-Host ">>> Resolve-DnsName -Type TXT -Name $hostAddress"
    Resolve-DnsName -Type TXT -Name "$hostAddress" | Format-Table -AutoSize
}

function dign([string]$hostAddress) {
    Write-Host ">>> Resolve-DnsName -Type NS -Name $hostAddress"
    Resolve-DnsName -Type NS -Name "$hostAddress" | Format-Table -AutoSize -Property Name,Type,TTL,Section,NameHost,Strings
}

function digs([string]$hostAddress) {
    Write-Host ">>> Resolve-DnsName -Type SOA -Name $hostAddress"
    Resolve-DnsName -Type SOA -Name "$hostAddress" | Format-Table -AutoSize -Property Name,Type,TTL,Section,PrimaryServer,NameAdministrator,SerialNumber,Strings
}

function digp([string]$hostAddress) {
    Write-Host ">>> Resolve-DnsName -Type PTR -Name $hostAddress"
    Resolve-DnsName -Type PTR -Name "$hostAddress" | Format-Table -AutoSize -Property Name,Type,TTL,Section,NameHost,Strings
}

## DNS checking commands - end



## Gets the Public IP Address of WAN Interface
# mywan aka mw
function mw {
    Write-Host ">>> (Invoke-WebRequest http://ifconfig.me/ip ).Content"
    #$wanIP = Invoke-WebRequest ifconfig.io | Select-Object -ExpandProperty Content
    $wanIP = (Invoke-WebRequest http://ifconfig.me/ip ).Content
    Write-Host $wanIP -ForegroundColor Green
    #Write-Host ">>> Invoke-RestMethod -Method Get -Uri http://ip-api.com/json/$wanIP"
    #Invoke-RestMethod -Method Get -Uri "http://ip-api.com/json/$wanIP"
}

## Ping like linux
function p([string]$hostAddress) {
    ping -t "$hostAddress"
}

# Winget Search App
function wgs([string]$wingetID) {
    if ($wingetID) {
        Write-Host ">>> winget search $wingetID" -ForegroundColor Green
        winget search "$wingetID"
    } else {
        Write-Host ">>> To use custom function, You need to type: wgs appName" -ForegroundColor Red
    }
}

# Winget Install App
function wgi([string]$wingetID) {
    if ($wingetID) {
        Write-Host ">>> winget install -e $wingetID --accept-package-agreements -h -s winget" -ForegroundColor Green
        winget install -e "$wingetID" --accept-package-agreements -h -s winget
    } else {
        Write-Host ">>> Check the Package ID and try again. It needs to match exactly" -ForegroundColor Red
    }
}

# Alias example: Set-Alias MyAlias runActualCommand

Set-Alias wg winget

Set-Alias v nvim

Set-Alias htop ntop

Set-Alias ll ls




## Alias Ends

## New Shell windows open with date shown
Get-date


## Run Oh-My-Posh https://dev.to/ansonh/customize-beautify-your-windows-terminal-2022-edition-541l
## Theme: change path after --config to point at a theme stored in: ~\AppData\Local\Programs\oh-my-posh\themes
oh-my-posh --init --shell pwsh --config "$HOME\Documents\GitHub\powershellProfile\negligible-noTime.omp.json" | Invoke-Expression
#oh-my-posh --init --shell pwsh --config $HOME/AppData/Local/Programs/oh-my-posh/themes/negligible.omp.json | Invoke-Expression
#Default: jandedobbeleer.omp.json
#minimal: wopian.omp.json
# star.omp.json
# busy: multiverse-neon
# negligible