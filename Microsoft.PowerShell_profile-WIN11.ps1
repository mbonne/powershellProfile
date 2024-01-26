## https://stackoverflow.com/questions/24914589/how-to-create-permanent-powershell-aliases
## https://www.howtogeek.com/50236/customizing-your-powershell-profile/
## https://thesmashy.medium.com/helpful-functions-for-your-powershell-profile-9fece679f4d6
## create symbolic links windows: https://woshub.com/create-symlink-windows/

## This profile is setup with following sections

## Path additions for cli tools
## https://stackoverflow.com/questions/714877/setting-windows-powershell-environment-variables

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


# Function example
# function Do-ActualThing {
#     # do actual thing
# }

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

## Poormans Grep
# look for string in text
## Example: grep  <string
# look for string from pipe
## Example: Get-ChildItem *.txt | grep "error"
function grep($pattern) {
    $input | Out-String -Stream| Select-String $pattern
}

## https://stackoverflow.com/questions/16651883/server-uptime-need-days-only-powershell
function uptime {
    $bootuptime = (Get-CimInstance -ClassName Win32_OperatingSystem).LastBootUpTime
    $CurrentDate = Get-Date
    $uptime = $CurrentDate - $bootuptime
    Write-Host "Uptime --> Days: $($uptime.days), Hours: $($uptime.Hours), Minutes:$($uptime.Minutes)"  -ForegroundColor green
    # detailed output just use $uptime on its own

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
function mywan {
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