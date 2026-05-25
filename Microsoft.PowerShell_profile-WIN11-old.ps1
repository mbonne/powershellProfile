# PowerShell Profile Configuration

# References
# https://stackoverflow.com/questions/24914589/how-to-create-permanent-powershell-aliases
# https://www.howtogeek.com/50236/customizing-your-powershell-profile/
# https://thesmashy.medium.com/helpful-functions-for-your-powershell-profile-9fece679f4d6
# https://woshub.com/create-symlink-windows/

# Path additions for CLI tools
$env:PATH += ";C:\Program Files\iperf3\iperf-3.1.3-win64"

# Path to Terminal App settings
$terminalSettings = "$HOME\AppData\Local\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"

# Import custom PowerShell modules
$customModulesPath = "$HOME\Documents\GitHub\pwsh\Modules\"
if (Test-Path $customModulesPath) {
  Write-Host "Importing Custom Modules from $customModulesPath" -ForegroundColor Green
  Get-ChildItem $customModulesPath -Recurse -Filter *.psm1 | ForEach-Object { Import-Module $_.FullName }
} else {
  Write-Host "Unable to install Custom Modules. Folder Doesn't Exist. Clone Repo: https://github.com/mbonne/pwsh" -ForegroundColor Red
}

# PSReadLine Configuration
$PSReadLineOptions = @{
  EditMode = "Emacs"
  HistoryNoDuplicates = $true
  BellStyle = "None"
  Colors = @{
    "Command" = "#56B6C2"
    "String" = "#98C379"
    "Number" = "#D19A66"
    "Variable" = "#E06C75"
    "Keyword" = "#C678DD"
    "Default" = "#D19A66"
    "Type" = "#61AFEF"
    "Member" = "#61AFEF"
  }
}
Set-PSReadLineOption @PSReadLineOptions

# Directory color customization for PowerShell 7+
if ($PSVersionTable.PSVersion.Major -ge 7) {
  $PSStyle.FileInfo.Directory = "`e[1m"
}

# PSReadLine Key Handlers
Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward
Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward
Set-PSReadLineKeyHandler -Key Ctrl+d -Function DeleteCharOrExit

# Aliases
Set-Alias wg winget
Set-Alias v nvim
Set-Alias htop ntop
Set-Alias ll ls
if ($PSVersionTable.PSVersion.Major -ge 7) {
  Set-Alias cat bat
}

# Functions
function source { & $PROFILE }
function genpass { -join(48..57+65..90+97..122 | ForEach-Object { [char]$_ } | Get-Random -Count 20) }
function Green { process { Write-Host $_ -ForegroundColor Green } }
function Red { process { Write-Host $_ -ForegroundColor Red } }
function ln ([string]$symlink, [string]$target) {
  if ($symlink -and $target) {
    Write-Output ">>> New-Item -ItemType SymbolicLink -Path $symlink -Target $target" | Green
    New-Item -ItemType SymbolicLink -Path $symlink -Target $target
  } else {
    Write-Output ">>> You need to specify both Symbolic Link file name AND the original target file" | Red
  }
}
function mv ([string]$targetObj, [string]$destinationObj) {
  Write-Host ">>> Move-Item -Path $targetObj -Destination $destinationObj -Confirm"
  Move-Item -Path $targetObj -Destination $destinationObj -Confirm
}
function grep ($regex, $dir) {
  if ($dir) {
    Get-ChildItem $dir | Select-String $regex
  } else {
    $input | Select-String $regex
  }
}
function ip {
  Write-Output ">>> get-netipaddress -AddressFamily IPv4 | Where-Object PrefixOrigin -ne 'WellKnown' | Select-Object InterfaceAlias, IPAddress, PrefixLength, PrefixOrigin" | Green
  get-netipaddress -AddressFamily IPv4 | Where-Object PrefixOrigin -ne "WellKnown" | Select-Object InterfaceAlias, IPAddress, PrefixLength, PrefixOrigin
}
function ipint {
  Write-Output ">>> get-netipinterface | Sort-Object -Property InterfaceMetric | Where-Object -Property ConnectionState -ne 'Disconnected'" | Green
  get-netipinterface | Sort-Object -Property InterfaceMetric | Where-Object -Property ConnectionState -ne "Disconnected"
}
function dig ([string]$hostAddress) {
  Write-Host ">>> Resolve-DnsName -Name $hostAddress"
  Resolve-DnsName -Name "$hostAddress"
}
function diga ([string]$hostAddress) {
  Write-Host ">>> Resolve-DnsName -Type A -Name $hostAddress"
  $digAnswer = Resolve-DnsName -Type A -Name "$hostAddress"
  Write-Output ($digAnswer).IPAddress | Green
  $digAnswer | Format-Table -AutoSize -Property Name,Type,TTL,Section,IPAddress,Strings
}
function digc ([string]$hostAddress) {
  Write-Host ">>> Resolve-DnsName -Type CNAME -Name $hostAddress"
  $digAnswer = Resolve-DnsName -Type CNAME -Name "$hostAddress"
  Write-Output ($digAnswer).IPAddress | Green
  $digAnswer | Format-Table -AutoSize -Property Name,Type,TTL,Section,NameHost,Strings
}
function digm ([string]$hostAddress) {
  Write-Host ">>> Resolve-DnsName -Type MX -Name $hostAddress"
  Resolve-DnsName -Type MX -Name "$hostAddress" | Format-Table -AutoSize -Property Name,Type,TTL,Section,NameExchange,Preference,Strings
}
function digt ([string]$hostAddress) {
  Write-Host ">>> Resolve-DnsName -Type TXT -Name $hostAddress"
  Resolve-DnsName -Type TXT -Name "$hostAddress" | Format-Table -AutoSize
}
function dign ([string]$hostAddress) {
  Write-Host ">>> Resolve-DnsName -Type NS -Name $hostAddress"
  Resolve-DnsName -Type NS -Name "$hostAddress" | Format-Table -AutoSize -Property Name,Type,TTL,Section,NameHost,Strings
}
function digs ([string]$hostAddress) {
  Write-Host ">>> Resolve-DnsName -Type SOA -Name $hostAddress"
  Resolve-DnsName -Type SOA -Name "$hostAddress" | Format-Table -AutoSize -Property Name,Type,TTL,Section,PrimaryServer,NameAdministrator,SerialNumber,Strings
}
function digp ([string]$hostAddress) {
  Write-Host ">>> Resolve-DnsName -Type PTR -Name $hostAddress"
  Resolve-DnsName -Type PTR -Name "$hostAddress" | Format-Table -AutoSize -Property Name,Type,TTL,Section,NameHost,Strings
}
function mw {
  Write-Host ">>> (Invoke-WebRequest http://ifconfig.me/ip ).Content"
  $wanIP = (Invoke-WebRequest http://ifconfig.me/ip ).Content
  Write-Host $wanIP -ForegroundColor Green
}
function p ([string]$hostAddress) {
  ping -t "$hostAddress"
}
function wgs ([string]$wingetID) {
  if ($wingetID) {
    Write-Host ">>> winget search $wingetID" -ForegroundColor Green
    winget search "$wingetID"
  } else {
    Write-Host ">>> To use custom function, You need to type: wgs appName" -ForegroundColor Red
  }
}
function wgi ([string]$wingetID) {
  if ($wingetID) {
    Write-Host ">>> winget install -e $wingetID --accept-package-agreements -h -s winget" -ForegroundColor Green
    winget install -e "$wingetID" --accept-package-agreements -h -s winget
  } else {
    Write-Host ">>> Check the Package ID and try again. It needs to match exactly" -ForegroundColor Red
  }
}

# Oh-My-Posh Initialization
oh-my-posh --init --shell pwsh --config "$HOME\Documents\GitHub\powershellProfile\themes\dracula.omp.json" | Invoke-Expression

# Terminal Icons
Install-Module Terminal-Icons -Scope CurrentUser

# Zoxide Initialization
Invoke-Expression (& { (zoxide init powershell | Out-String) })

# FZF Initialization
#Install-Module -Name PSFzf -Scope CurrentUser -AllowClobber -Force
Set-PsFzfOption -PSReadlineChordProvider 'Ctrl+t' -PSReadlineChordReverseHistory 'Ctrl+r'
Set-PSReadLineKeyHandler -Key Tab -ScriptBlock { Invoke-FzfTabCompletion }
Set-PsFzfOption -TabExpansion
Set-Alias fkill Invoke-FuzzyKillProcess

# FZF and eza Configuration
$env:FZF_DEFAULT_OPTS = @"
--layout=reverse
--cycle
--scroll-off=5
--border
--preview-window=right,60%,border-left
--bind ctrl-u:preview-half-page-up
--bind ctrl-d:preview-half-page-down
--bind ctrl-f:preview-page-down
--bind ctrl-b:preview-page-up
--bind ctrl-g:preview-top
--bind ctrl-h:preview-bottom
--bind alt-w:toggle-preview-wrap
--bind ctrl-e:toggle-preview
"@

function _open_path {
  param ([string]$input_path)
  if (-not $input_path) { return }
  Write-Output "[ ] cd"
  Write-Output "[*] nvim"
  $choice = Read-Host "Enter your choice"
  if ($input_path -match "^.*:\d+:.*$") {
    $input_path = ($input_path -split ":")[0]
  }
  switch ($choice) {
    {$_ -eq "" -or $_ -eq " "} {
      if (Test-Path -Path $input_path -PathType Leaf) {
        $input_path = Split-Path -Path $input_path -Parent
      }
      Set-Location -Path $input_path
    }
    default { nvim $input_path }
  }
}

function _get_path_using_fd {
  $input_path = fd --type file --follow --hidden --exclude .git |
    fzf --prompt 'Files> ' `
      --header-first `
      --header 'CTRL-S: Switch between Files/Directories' `
      --bind 'ctrl-s:transform:if not "%FZF_PROMPT%"=="Files> " (echo ^change-prompt^(Files^> ^)^+^reload^(fd --type file^)) else (echo ^change-prompt^(Directory^> ^)^+^reload^(fd --type directory^))' `
      --preview 'if "%FZF_PROMPT%"=="Files> " (bat --color=always {} --style=plain) else (eza -T --level=2 --colour=always --icons=always {})'
  return $input_path
}

function _get_path_using_rg {
  $INITIAL_QUERY = "${*:-}"
  $RG_PREFIX = "rg --column --line-number --no-heading --color=always --smart-case"
  $input_path = "" |
    fzf --ansi --disabled --query "$INITIAL_QUERY" `
      --bind "start:reload:$RG_PREFIX {q}" `
      --bind "change:reload:sleep 0.1 & $RG_PREFIX {q} || rem" `
      --bind 'ctrl-s:transform:if not "%FZF_PROMPT%" == "1. ripgrep> " (echo ^rebind^(change^)^+^change-prompt^(1. ripgrep^> ^)^+^disable-search^+^transform-query:echo ^{q^} ^> %TEMP%\rg-fzf-f ^& cat %TEMP%\rg-fzf-r) else (echo ^unbind^(change^)^+^change-prompt^(2. fzf^> ^)^+^enable-search^+^transform-query:echo ^{q^} ^> %TEMP%\rg-fzf-r ^& cat %TEMP%\rg-fzf-f)' `
      --color "hl:-1:underline,hl+:-1:underline:reverse" `
      --delimiter ":" `
      --prompt '1. ripgrep> ' `
      --preview-label "Preview" `
      --header 'CTRL-S: Switch between ripgrep/fzf' `
      --header-first `
      --preview 'bat --color=always {1} --highlight-line {2} --style=plain' `
      --preview-window 'up,60%,border-bottom,+{2}+3/3'
  return $input_path
}

function fdg { _open_path $(_get_path_using_fd) }
function rgg { _open_path $(_get_path_using_rg) }

# Set Keyboard Shortcuts for FZF
Set-PSReadLineKeyHandler -Key "Ctrl+f" -ScriptBlock {
  [Microsoft.PowerShell.PSConsoleReadLine]::RevertLine()
  [Microsoft.PowerShell.PSConsoleReadLine]::Insert("fdg")
  [Microsoft.PowerShell.PSConsoleReadLine]::AcceptLine()
}
Set-PSReadLineKeyHandler -Key "Ctrl+g" -ScriptBlock {
  [Microsoft.PowerShell.PSConsoleReadLine]::RevertLine()
  [Microsoft.PowerShell.PSConsoleReadLine]::Insert("rgg")
  [Microsoft.PowerShell.PSConsoleReadLine]::AcceptLine()
}

# Display current date on new shell window
Get-Date

# SIG # Begin signature block
# MIIb2gYJKoZIhvcNAQcCoIIbyzCCG8cCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUWVEqrkCiZReqOvMiU8CHL1jN
# bz2gghZIMIIDCjCCAfKgAwIBAgIQN3ZxlYIRy4BPqrn//00vETANBgkqhkiG9w0B
# AQsFADAdMRswGQYDVQQDDBJMb2NhbFNjcmlwdFNpZ25pbmcwHhcNMjYwMTA5MDUx
# NzI0WhcNMjkwMTA5MDUyNzI1WjAdMRswGQYDVQQDDBJMb2NhbFNjcmlwdFNpZ25p
# bmcwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQDCG4o2wfltl7uu3au3
# t3yhASNCw2Rfl9rXglcpTqJTUGgkblwF83+SOccQc6MXh1Xr4vhY10Ah4dzGx74s
# U+qFLc+2y+i6uZrGPkaKMgR/qDnIP8MUHWa9P+6BfkT6wZvTiZHq1P+5WNBf/y2X
# RVQ1rWnPek9B7wfHReQYzI5J2U0MhL3updzD1i2BPkqrrArjHgKKhHaTyj7L8Xzl
# iu2gBslKEGwIZooFT/sM+k2KIKnHgoP2N7++Cs6z/KDLJQ8jGnO/TySR0XGGmHxA
# ysMe4F1UBriRoGA6TqSe9DCkkog33aPLlQ4PW5GD9RA71/XQI0ZxW0XEOI3pfyQo
# V2OlAgMBAAGjRjBEMA4GA1UdDwEB/wQEAwIHgDATBgNVHSUEDDAKBggrBgEFBQcD
# AzAdBgNVHQ4EFgQUngs4XZNzAq/yhw7mk79Rl9d7s4wwDQYJKoZIhvcNAQELBQAD
# ggEBAFnvqlsj6Fo3iOh2QmHZREWilHQS0sP0YYzawav2Apz2hQCwd/4oNAWhfIUZ
# 1gBA+CKfIvr7luc/R/7W4vUG6z3NHban4mKhfo2AXhTbxLeGBKgvlt2uDcf4x50e
# 4gaOudrJiN/izyGeoArss+Jbf9BwQ4Q3fvOWINgmLq/lnsleoyXsolilGdD64IMX
# 6cy3UhsrRJJ6xtJl4IuGcMl5HxzDS9yRgnyQ+sqmVrjBjit/rI8lSmDUsEAqaHfI
# np4V4f2hBWWlmYoJgx/6gazARn9ufwGAILVS6SAT5kO4LdYy6J8d+dt7atSfFlv2
# 48Qnme5BVM5uMcISZYXos4Ummq8wggWNMIIEdaADAgECAhAOmxiO+dAt5+/bUOII
# QBhaMA0GCSqGSIb3DQEBDAUAMGUxCzAJBgNVBAYTAlVTMRUwEwYDVQQKEwxEaWdp
# Q2VydCBJbmMxGTAXBgNVBAsTEHd3dy5kaWdpY2VydC5jb20xJDAiBgNVBAMTG0Rp
# Z2lDZXJ0IEFzc3VyZWQgSUQgUm9vdCBDQTAeFw0yMjA4MDEwMDAwMDBaFw0zMTEx
# MDkyMzU5NTlaMGIxCzAJBgNVBAYTAlVTMRUwEwYDVQQKEwxEaWdpQ2VydCBJbmMx
# GTAXBgNVBAsTEHd3dy5kaWdpY2VydC5jb20xITAfBgNVBAMTGERpZ2lDZXJ0IFRy
# dXN0ZWQgUm9vdCBHNDCCAiIwDQYJKoZIhvcNAQEBBQADggIPADCCAgoCggIBAL/m
# kHNo3rvkXUo8MCIwaTPswqclLskhPfKK2FnC4SmnPVirdprNrnsbhA3EMB/zG6Q4
# FutWxpdtHauyefLKEdLkX9YFPFIPUh/GnhWlfr6fqVcWWVVyr2iTcMKyunWZanMy
# lNEQRBAu34LzB4TmdDttceItDBvuINXJIB1jKS3O7F5OyJP4IWGbNOsFxl7sWxq8
# 68nPzaw0QF+xembud8hIqGZXV59UWI4MK7dPpzDZVu7Ke13jrclPXuU15zHL2pNe
# 3I6PgNq2kZhAkHnDeMe2scS1ahg4AxCN2NQ3pC4FfYj1gj4QkXCrVYJBMtfbBHMq
# bpEBfCFM1LyuGwN1XXhm2ToxRJozQL8I11pJpMLmqaBn3aQnvKFPObURWBf3JFxG
# j2T3wWmIdph2PVldQnaHiZdpekjw4KISG2aadMreSx7nDmOu5tTvkpI6nj3cAORF
# JYm2mkQZK37AlLTSYW3rM9nF30sEAMx9HJXDj/chsrIRt7t/8tWMcCxBYKqxYxhE
# lRp2Yn72gLD76GSmM9GJB+G9t+ZDpBi4pncB4Q+UDCEdslQpJYls5Q5SUUd0vias
# tkF13nqsX40/ybzTQRESW+UQUOsxxcpyFiIJ33xMdT9j7CFfxCBRa2+xq4aLT8LW
# RV+dIPyhHsXAj6KxfgommfXkaS+YHS312amyHeUbAgMBAAGjggE6MIIBNjAPBgNV
# HRMBAf8EBTADAQH/MB0GA1UdDgQWBBTs1+OC0nFdZEzfLmc/57qYrhwPTzAfBgNV
# HSMEGDAWgBRF66Kv9JLLgjEtUYunpyGd823IDzAOBgNVHQ8BAf8EBAMCAYYweQYI
# KwYBBQUHAQEEbTBrMCQGCCsGAQUFBzABhhhodHRwOi8vb2NzcC5kaWdpY2VydC5j
# b20wQwYIKwYBBQUHMAKGN2h0dHA6Ly9jYWNlcnRzLmRpZ2ljZXJ0LmNvbS9EaWdp
# Q2VydEFzc3VyZWRJRFJvb3RDQS5jcnQwRQYDVR0fBD4wPDA6oDigNoY0aHR0cDov
# L2NybDMuZGlnaWNlcnQuY29tL0RpZ2lDZXJ0QXNzdXJlZElEUm9vdENBLmNybDAR
# BgNVHSAECjAIMAYGBFUdIAAwDQYJKoZIhvcNAQEMBQADggEBAHCgv0NcVec4X6Cj
# dBs9thbX979XB72arKGHLOyFXqkauyL4hxppVCLtpIh3bb0aFPQTSnovLbc47/T/
# gLn4offyct4kvFIDyE7QKt76LVbP+fT3rDB6mouyXtTP0UNEm0Mh65ZyoUi0mcud
# T6cGAxN3J0TU53/oWajwvy8LpunyNDzs9wPHh6jSTEAZNUZqaVSwuKFWjuyk1T3o
# sdz9HNj0d1pcVIxv76FQPfx2CWiEn2/K2yCNNWAcAgPLILCsWKAOQGPFmCLBsln1
# VWvPJ6tsds5vIy30fnFqI2si/xK4VC0nftg62fC2h5b9W9FcrBjDTZ9ztwGpn1eq
# XijiuZQwgga0MIIEnKADAgECAhANx6xXBf8hmS5AQyIMOkmGMA0GCSqGSIb3DQEB
# CwUAMGIxCzAJBgNVBAYTAlVTMRUwEwYDVQQKEwxEaWdpQ2VydCBJbmMxGTAXBgNV
# BAsTEHd3dy5kaWdpY2VydC5jb20xITAfBgNVBAMTGERpZ2lDZXJ0IFRydXN0ZWQg
# Um9vdCBHNDAeFw0yNTA1MDcwMDAwMDBaFw0zODAxMTQyMzU5NTlaMGkxCzAJBgNV
# BAYTAlVTMRcwFQYDVQQKEw5EaWdpQ2VydCwgSW5jLjFBMD8GA1UEAxM4RGlnaUNl
# cnQgVHJ1c3RlZCBHNCBUaW1lU3RhbXBpbmcgUlNBNDA5NiBTSEEyNTYgMjAyNSBD
# QTEwggIiMA0GCSqGSIb3DQEBAQUAA4ICDwAwggIKAoICAQC0eDHTCphBcr48RsAc
# rHXbo0ZodLRRF51NrY0NlLWZloMsVO1DahGPNRcybEKq+RuwOnPhof6pvF4uGjwj
# qNjfEvUi6wuim5bap+0lgloM2zX4kftn5B1IpYzTqpyFQ/4Bt0mAxAHeHYNnQxqX
# mRinvuNgxVBdJkf77S2uPoCj7GH8BLuxBG5AvftBdsOECS1UkxBvMgEdgkFiDNYi
# OTx4OtiFcMSkqTtF2hfQz3zQSku2Ws3IfDReb6e3mmdglTcaarps0wjUjsZvkgFk
# riK9tUKJm/s80FiocSk1VYLZlDwFt+cVFBURJg6zMUjZa/zbCclF83bRVFLeGkuA
# hHiGPMvSGmhgaTzVyhYn4p0+8y9oHRaQT/aofEnS5xLrfxnGpTXiUOeSLsJygoLP
# p66bkDX1ZlAeSpQl92QOMeRxykvq6gbylsXQskBBBnGy3tW/AMOMCZIVNSaz7BX8
# VtYGqLt9MmeOreGPRdtBx3yGOP+rx3rKWDEJlIqLXvJWnY0v5ydPpOjL6s36czwz
# sucuoKs7Yk/ehb//Wx+5kMqIMRvUBDx6z1ev+7psNOdgJMoiwOrUG2ZdSoQbU2rM
# kpLiQ6bGRinZbI4OLu9BMIFm1UUl9VnePs6BaaeEWvjJSjNm2qA+sdFUeEY0qVjP
# KOWug/G6X5uAiynM7Bu2ayBjUwIDAQABo4IBXTCCAVkwEgYDVR0TAQH/BAgwBgEB
# /wIBADAdBgNVHQ4EFgQU729TSunkBnx6yuKQVvYv1Ensy04wHwYDVR0jBBgwFoAU
# 7NfjgtJxXWRM3y5nP+e6mK4cD08wDgYDVR0PAQH/BAQDAgGGMBMGA1UdJQQMMAoG
# CCsGAQUFBwMIMHcGCCsGAQUFBwEBBGswaTAkBggrBgEFBQcwAYYYaHR0cDovL29j
# c3AuZGlnaWNlcnQuY29tMEEGCCsGAQUFBzAChjVodHRwOi8vY2FjZXJ0cy5kaWdp
# Y2VydC5jb20vRGlnaUNlcnRUcnVzdGVkUm9vdEc0LmNydDBDBgNVHR8EPDA6MDig
# NqA0hjJodHRwOi8vY3JsMy5kaWdpY2VydC5jb20vRGlnaUNlcnRUcnVzdGVkUm9v
# dEc0LmNybDAgBgNVHSAEGTAXMAgGBmeBDAEEAjALBglghkgBhv1sBwEwDQYJKoZI
# hvcNAQELBQADggIBABfO+xaAHP4HPRF2cTC9vgvItTSmf83Qh8WIGjB/T8ObXAZz
# 8OjuhUxjaaFdleMM0lBryPTQM2qEJPe36zwbSI/mS83afsl3YTj+IQhQE7jU/kXj
# jytJgnn0hvrV6hqWGd3rLAUt6vJy9lMDPjTLxLgXf9r5nWMQwr8Myb9rEVKChHyf
# pzee5kH0F8HABBgr0UdqirZ7bowe9Vj2AIMD8liyrukZ2iA/wdG2th9y1IsA0QF8
# dTXqvcnTmpfeQh35k5zOCPmSNq1UH410ANVko43+Cdmu4y81hjajV/gxdEkMx1NK
# U4uHQcKfZxAvBAKqMVuqte69M9J6A47OvgRaPs+2ykgcGV00TYr2Lr3ty9qIijan
# rUR3anzEwlvzZiiyfTPjLbnFRsjsYg39OlV8cipDoq7+qNNjqFzeGxcytL5TTLL4
# ZaoBdqbhOhZ3ZRDUphPvSRmMThi0vw9vODRzW6AxnJll38F0cuJG7uEBYTptMSbh
# dhGQDpOXgpIUsWTjd6xpR6oaQf/DJbg3s6KCLPAlZ66RzIg9sC+NJpud/v4+7RWs
# WCiKi9EOLLHfMR2ZyJ/+xhCx9yHbxtl5TPau1j/1MIDpMPx0LckTetiSuEtQvLsN
# z3Qbp7wGWqbIiOWCnb5WqxL3/BAPvIXKUjPSxyZsq8WhbaM2tszWkPZPubdcMIIG
# 7TCCBNWgAwIBAgIQCoDvGEuN8QWC0cR2p5V0aDANBgkqhkiG9w0BAQsFADBpMQsw
# CQYDVQQGEwJVUzEXMBUGA1UEChMORGlnaUNlcnQsIEluYy4xQTA/BgNVBAMTOERp
# Z2lDZXJ0IFRydXN0ZWQgRzQgVGltZVN0YW1waW5nIFJTQTQwOTYgU0hBMjU2IDIw
# MjUgQ0ExMB4XDTI1MDYwNDAwMDAwMFoXDTM2MDkwMzIzNTk1OVowYzELMAkGA1UE
# BhMCVVMxFzAVBgNVBAoTDkRpZ2lDZXJ0LCBJbmMuMTswOQYDVQQDEzJEaWdpQ2Vy
# dCBTSEEyNTYgUlNBNDA5NiBUaW1lc3RhbXAgUmVzcG9uZGVyIDIwMjUgMTCCAiIw
# DQYJKoZIhvcNAQEBBQADggIPADCCAgoCggIBANBGrC0Sxp7Q6q5gVrMrV7pvUf+G
# cAoB38o3zBlCMGMyqJnfFNZx+wvA69HFTBdwbHwBSOeLpvPnZ8ZN+vo8dE2/pPvO
# x/Vj8TchTySA2R4QKpVD7dvNZh6wW2R6kSu9RJt/4QhguSssp3qome7MrxVyfQO9
# sMx6ZAWjFDYOzDi8SOhPUWlLnh00Cll8pjrUcCV3K3E0zz09ldQ//nBZZREr4h/G
# I6Dxb2UoyrN0ijtUDVHRXdmncOOMA3CoB/iUSROUINDT98oksouTMYFOnHoRh6+8
# 6Ltc5zjPKHW5KqCvpSduSwhwUmotuQhcg9tw2YD3w6ySSSu+3qU8DD+nigNJFmt6
# LAHvH3KSuNLoZLc1Hf2JNMVL4Q1OpbybpMe46YceNA0LfNsnqcnpJeItK/DhKbPx
# TTuGoX7wJNdoRORVbPR1VVnDuSeHVZlc4seAO+6d2sC26/PQPdP51ho1zBp+xUIZ
# kpSFA8vWdoUoHLWnqWU3dCCyFG1roSrgHjSHlq8xymLnjCbSLZ49kPmk8iyyizND
# IXj//cOgrY7rlRyTlaCCfw7aSUROwnu7zER6EaJ+AliL7ojTdS5PWPsWeupWs7Np
# ChUk555K096V1hE0yZIXe+giAwW00aHzrDchIc2bQhpp0IoKRR7YufAkprxMiXAJ
# Q1XCmnCfgPf8+3mnAgMBAAGjggGVMIIBkTAMBgNVHRMBAf8EAjAAMB0GA1UdDgQW
# BBTkO/zyMe39/dfzkXFjGVBDz2GM6DAfBgNVHSMEGDAWgBTvb1NK6eQGfHrK4pBW
# 9i/USezLTjAOBgNVHQ8BAf8EBAMCB4AwFgYDVR0lAQH/BAwwCgYIKwYBBQUHAwgw
# gZUGCCsGAQUFBwEBBIGIMIGFMCQGCCsGAQUFBzABhhhodHRwOi8vb2NzcC5kaWdp
# Y2VydC5jb20wXQYIKwYBBQUHMAKGUWh0dHA6Ly9jYWNlcnRzLmRpZ2ljZXJ0LmNv
# bS9EaWdpQ2VydFRydXN0ZWRHNFRpbWVTdGFtcGluZ1JTQTQwOTZTSEEyNTYyMDI1
# Q0ExLmNydDBfBgNVHR8EWDBWMFSgUqBQhk5odHRwOi8vY3JsMy5kaWdpY2VydC5j
# b20vRGlnaUNlcnRUcnVzdGVkRzRUaW1lU3RhbXBpbmdSU0E0MDk2U0hBMjU2MjAy
# NUNBMS5jcmwwIAYDVR0gBBkwFzAIBgZngQwBBAIwCwYJYIZIAYb9bAcBMA0GCSqG
# SIb3DQEBCwUAA4ICAQBlKq3xHCcEua5gQezRCESeY0ByIfjk9iJP2zWLpQq1b4UR
# GnwWBdEZD9gBq9fNaNmFj6Eh8/YmRDfxT7C0k8FUFqNh+tshgb4O6Lgjg8K8elC4
# +oWCqnU/ML9lFfim8/9yJmZSe2F8AQ/UdKFOtj7YMTmqPO9mzskgiC3QYIUP2S3H
# QvHG1FDu+WUqW4daIqToXFE/JQ/EABgfZXLWU0ziTN6R3ygQBHMUBaB5bdrPbF6M
# RYs03h4obEMnxYOX8VBRKe1uNnzQVTeLni2nHkX/QqvXnNb+YkDFkxUGtMTaiLR9
# wjxUxu2hECZpqyU1d0IbX6Wq8/gVutDojBIFeRlqAcuEVT0cKsb+zJNEsuEB7O7/
# cuvTQasnM9AWcIQfVjnzrvwiCZ85EE8LUkqRhoS3Y50OHgaY7T/lwd6UArb+BOVA
# kg2oOvol/DJgddJ35XTxfUlQ+8Hggt8l2Yv7roancJIFcbojBcxlRcGG0LIhp6Gv
# ReQGgMgYxQbV1S3CrWqZzBt1R9xJgKf47CdxVRd/ndUlQ05oxYy2zRWVFjF7mcr4
# C34Mj3ocCVccAvlKV9jEnstrniLvUxxVZE/rptb7IRE2lskKPIJgbaP5t2nGj/UL
# Li49xTcBZU8atufk+EMF/cWuiC7POGT75qaL6vdCvHlshtjdNXOCIUjsarfNZzGC
# BPwwggT4AgEBMDEwHTEbMBkGA1UEAwwSTG9jYWxTY3JpcHRTaWduaW5nAhA3dnGV
# ghHLgE+quf//TS8RMAkGBSsOAwIaBQCgeDAYBgorBgEEAYI3AgEMMQowCKACgACh
# AoAAMBkGCSqGSIb3DQEJAzEMBgorBgEEAYI3AgEEMBwGCisGAQQBgjcCAQsxDjAM
# BgorBgEEAYI3AgEVMCMGCSqGSIb3DQEJBDEWBBQUfXSsP04OgG5jGIZshAgA9Rxh
# nDANBgkqhkiG9w0BAQEFAASCAQBF80THw769m1hI7QFVuhkwf7Sa/vVKF/ptxfxu
# dqWGMmrwQpVbrnzXDQsQAFpfH1CkibP0ZY3mFAN4Y/pSQtDjY7l+hQXWy4jLVQAr
# QC/1KQPVbxBtRaIx8YAmmur/m5r4vNhYkFIwlULVtp9RnNTSbOzZgCD/IxWSZlfM
# lD8ov6UAePL828RVAbtfFCeHbQez2E1wXGmYzFBZouSwCnWLDzhk0lVNHgm0YbpY
# kpIgMGk+VEHjkBh9+07b9zPh6BURHKwM1CWJoafQQB44cFITXZS60+PzfA6mbWTu
# x3j9LJM0kB5jMXvQAN3GzrMgKZdb8LM2iiy/LmiaD6rmKoR1oYIDJjCCAyIGCSqG
# SIb3DQEJBjGCAxMwggMPAgEBMH0waTELMAkGA1UEBhMCVVMxFzAVBgNVBAoTDkRp
# Z2lDZXJ0LCBJbmMuMUEwPwYDVQQDEzhEaWdpQ2VydCBUcnVzdGVkIEc0IFRpbWVT
# dGFtcGluZyBSU0E0MDk2IFNIQTI1NiAyMDI1IENBMQIQCoDvGEuN8QWC0cR2p5V0
# aDANBglghkgBZQMEAgEFAKBpMBgGCSqGSIb3DQEJAzELBgkqhkiG9w0BBwEwHAYJ
# KoZIhvcNAQkFMQ8XDTI2MDEwOTA2MDEyNFowLwYJKoZIhvcNAQkEMSIEIA01DWRi
# wyVmw96fP55NzR2D6Mni999KbDkixprCqZY9MA0GCSqGSIb3DQEBAQUABIICAEOC
# u6RwecaI+jW4o2tbiEvasGw4FfFjljdxROHOOAJaZg1Z41u/amzKKLEz5/syOuYy
# EAYYtfykaDTNzHXXEH+i7Bm61kvmTfA91XzdKnSoSBEI4Inn6dQ7DBBfFOXcMvRa
# jPCGRCkOU7Mg+PtogBCyqpyhFtEvhe2M79b5w3bxuhbbkTRRgWeIlfBRGWvA4zYe
# fHgGzaoO6lWxRiCFQwxG/fNj/lSBBRqMKqiSVxh7DC/54rUE3CKEqZ6MU44bm1G1
# s9EgCItBq9DT1uz3fY4j5InHDf8z98BhVJvI3ixiV4toGjiMLJzgaBYHVEVjGBvc
# NVDw5R7TJtNCF91vCa5TQjrkfGDEIp4Dybs/xMVYtCkP4j111fKjzfiQS8pyEjZb
# 6hu+VF9rCIJZQmlwWGdD73yuuhZKSgz+T548h84MW5BC7mAhFSPH+gvO7/7DoOr5
# KPiuaqCk5gIzjw/gClPN1zRIxoYy7ZaBdZ7RWn/ul76QmmsCYOXGF34L62LA/kvs
# 85Bf0I22MjwQ7TKPAuXLTmxZSadhFGtXkPOzaqi7hqBRFDZGulRW94jDwguLyahJ
# QyO0NwhK5EBphDthKYLI+3FUr2L/lNmaBRgWcu4QzKOw0B928vfK8VDzjIAH25jP
# 6DkNxTe1oQYRevxXSFAItHpOo+2dx9SPz7h7tVXB
# SIG # End signature block
