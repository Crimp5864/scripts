#Requires -Modules Log-Rotate

Import-Module -Name Log-Rotate -WarningAction SilentlyContinue

# Double-quotes necessary only if there are spaces in the path
$config = @'
"$env:LOCALAPPDATA\restic\restic.log" {
    rotate 4
    size 128K
    missingok
    notifempty
    copytruncate
}
'@

# Decide on a Log-Rotate state file that will be created by Log-Rotate
$stateDir  = "$env:LOCALAPPDATA\Log-Rotate"
if ( -not ( Test-Path -Path "$stateDir" -PathType Container ) ) {
    New-Item -ItemType Directory -Path "$stateDir" | Out-Null
}
$state = "$stateDir\Log-Rotate.status"

# To check rotation logic without rotating files, use the -WhatIf switch (implies -Verbose)
#$config | Log-Rotate -State $state -WhatIf

# You can either Pipe the config
#$config | Log-Rotate -State $state -Verbose

# Or use the full Command
Log-Rotate -ConfigAsString "$config" -State "$state"
