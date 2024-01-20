## https://stackoverflow.com/questions/24914589/how-to-create-permanent-powershell-aliases
## https://www.howtogeek.com/50236/customizing-your-powershell-profile/
## https://thesmashy.medium.com/helpful-functions-for-your-powershell-profile-9fece679f4d6
## create symbolic links windows: https://woshub.com/create-symlink-windows/

## This profile is setup with following sections

## Path additions for cli tools
## https://stackoverflow.com/questions/714877/setting-windows-powershell-environment-variables

## Functions to do more advanced things

## Alias to shorten commands

## Adding iPerf3 to path - https://iperf.fr/iperf-download.php
$env:PATH += ";C:\Program Files\iperf3\iperf-3.1.3-win64"


# Function example
# function Do-ActualThing {
#     # do actual thing
# }

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
    Write-Host ($digAnswer).IPAddress -ForegroundColor Green
    $digAnswer | Format-Table -AutoSize -Property Name,Type,TTL,Section,IPAddress,Strings
}

function digc([string]$hostAddress) {
    Write-Host ">>> Resolve-DnsName -Type CNAME -Name $hostAddress"
    $digAnswer = Resolve-DnsName -Type CNAME -Name "$hostAddress"
    Write-Host ($digAnswer).IPAddress -ForegroundColor Green
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

## JSON Pritty Print - Pipe the json via this function
## https://stackoverflow.com/questions/24789365/prettify-json-in-powershell-3
## Example:
## cat .\file.json | PrettyPrintJson
## curl https://api.twitter.com/1.1/statuses/user_timeline.json | PrettyPrintJson
function PrettyPrintJson {
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        $json
    )
    $json | ConvertFrom-Json | ConvertTo-Json -Depth 100
}

## Gets the Public IP Address of WAN Interface
function mywan {
    Write-Host ">>> (Invoke-WebRequest http://ifconfig.me/ip ).Content"
    #$wanIP = Invoke-WebRequest ifconfig.io | Select-Object -ExpandProperty Content
    $wanIP = (Invoke-WebRequest http://ifconfig.me/ip ).Content
    Write-Host $wanIP -ForegroundColor Green
    #Write-Host ">>> Invoke-RestMethod -Method Get -Uri http://ip-api.com/json/$wanIP"
    #Invoke-RestMethod -Method Get -Uri "http://ip-api.com/json/$wanIP"
}

## Geo Lookup of IP address - Uses mywan function defined above
## https://practical365.com/using-powershell-and-rest-api-requests-to-look-up-ip-address-geolocation-data/
# 
function geo([string]$hostAddress) {
    if ($hostAddress) {
        #$hostAddress has value
        #Write-Host "Checking Geo Location of $hostAddress"
    } else {
        #$hostAddress has no value
        $hostAddress = (Invoke-WebRequest http://ifconfig.me/ip ).Content
        Write-Host "No host targeted, using your current WAN IP: $hostAddress" -ForegroundColor Green
        Write-Host "To check Geo Location of a host, type geo then host IP or FQDN`n> geo example.com`nor`n> geo 1.1.1.1"
    }
    Write-Host ">>> Running nslookup against host with your current DNS server"
    nslookup $hostAddress
    Write-Host ">>> Getting Host Address Details from http://ip-api.com"
    $targetHostInfo = Invoke-RestMethod -Method Get -Uri "http://ip-api.com/json/$hostAddress"
    $targetHostInfo
    ## Find and remove all whitespace: https://stackoverflow.com/questions/24355760/removing-spaces-from-a-variable-input-using-powershell-4-0
    $targetHostIP = ($targetHostInfo).query -replace '\s',''
    $targetHostLat = ($targetHostInfo).lat -replace '\s',''
    $targetHostLon = ($targetHostInfo).lon -replace '\s',''

    # Create a menu: https://www.elevenforum.com/t/powershell-create-a-menu.4800/
    Write-Host "Some helpful links using the target host: $hostAddress" -ForegroundColor Green
    $mainMenu = {
        Write-Host
        Write-Host " 1.) Info about IP address: https://ipinfo.io/$targetHostIP"
        Write-Host " 2.) Talos Intelligence: https://talosintelligence.com/reputation_center/lookup?search=$hostAddress"
        Write-Host " 3.) VirusTotal: https://www.virustotal.com/gui/ip-address/$targetHostIP"
        Write-Host " 4.) Open Google Map: https://www.google.com/maps/@$targetHostLat,$targetHostLon,15z?entry=ttu"
        Write-Host " 5.) Quit"
        Write-Host
        Write-Host "Select an option and press Enter: "  -nonewline -ForegroundColor Green
        }
    Do {
        Invoke-Command $mainMenu
        $select = Read-Host
        Switch ($select)
            {
                1 {Start-Process "https://ipinfo.io/$targetHostIP"}
                2 {Start-Process "https://talosintelligence.com/reputation_center/lookup?search=$hostAddress"}
                3 {Start-Process "https://www.virustotal.com/gui/ip-address/$targetHostIP"}
                4 {Start-Process "https://www.google.com/maps/@$targetHostLat,$targetHostLon,15z?entry=ttu"}
            }
    }
    while ($select -ne 5)
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