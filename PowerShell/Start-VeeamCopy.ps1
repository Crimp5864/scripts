<#
.SYNOPSIS
    Cross-office Veeam backup sync script for 2-node workgroup.
#>

# --- Configuration & Variables ---
$Computers = @(
    "DESKTOP-PIC4K8H",
    "DESKTOP-EJ2CB7F"
)

$SrcComputer        = $env:COMPUTERNAME
$DestComputer       = $Computers | Where-Object { $_ -ne $SrcComputer }
$SrcPath            = "D:\VeeamBackup\$SrcComputer Daily Job\"
$DestPath           = "\\$DestComputer.local\$SrcComputer Daily Job Copy\"
$LogDir             = "$env:LOCALAPPDATA\Robocopy"
$LogFile            = "$LogDir\VeeamCopy.log"
$ThreadCount        = [Math]::Min( $env:NUMBER_OF_PROCESSORS, 16 )
$ErrorMessage       = "Robocopy encountered severe errors. Exit code"
$SuccessMessage     = "Robocopy completed successfully with code"

# Splat Parameters
$RobocopyArgs = @(
    $SrcPath,
    $DestPath,
    "*.*",
    "/E",
    "/PURGE",
    "/COPY:DAT",
    "/DCOPY:DAT",
    "/MT:$ThreadCount",
    "/R:3",
    "/W:5",
    "/LOG+:$LogFile",
    "/NP"#,
    #"/L" # Uncomment for dry run
)

# --- Functions ---
function Write-CustomLog {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Message
    )

    # Generate a fresh timestamp.
    $Timestamp = Get-Date -Format "MM/dd/yyyy hh:mm:ss tt"

    Add-Content -Path $LogFile -Value "$($Timestamp): $Message"
}

# --- Pre-Flight Checks ---
# Ensure this computer is authorized to run this script.
if ( $Computers -notcontains $SrcComputer ) {
    Write-Error -Message "Current computer ($SrcComputer) is not authorized."
    Exit 1
}

# Ensure log directory exists.
if ( -not ( Test-Path -Path $LogDir ) ) {
    New-Item -Path $LogDir -ItemType Directory -Force | Out-Null
}

# Ensure source path exists before starting.
if ( -not ( Test-Path -Path $SrcPath ) ) {
    $ErrText = "Source backup directory does not exist: $SrcPath."
    Write-CustomLog -Message $ErrText
    $MailParams = @{
        Subject     = "$SrcComputer Robocopy Failed"
        TextBody    = $ErrText
    }
    & "$PSScriptRoot\New-MailKitMessage.ps1" @MailParams
    exit 1
}

# Safely determine the destination.
if ( -not $DestPath -or $DestPath.Count -gt 1 ) {
    $ErrText = (
        "Could not uniquely determine destination. Ensure '$SrcComputer' " +
        "is listed and unique in the 'Computers' array."
    )
    Write-CustomLog -Message $ErrText
    exit 1
}

# --- Main Process ---
& Robocopy.exe @RobocopyArgs | Out-Null
$ExitCode = $LASTEXITCODE

# --- Error Handling & Notification ---
if ( $ExitCode -lt 8 ) {
    Write-CustomLog -Message "$SuccessMessage $ExitCode"
    $MailParams = @{
        Subject     = "$env:COMPUTERNAME Robocopy completed successfully."
        TextBody    = "$($SuccessMessage): $ExitCode"
    }
    & "$PSScriptRoot\New-MailKitMessage.ps1" @MailParams
    exit 0
}
else {
    Write-CustomLog -Message "$ErrorMessage $ExitCode"
    $MailParams = @{
        Subject     = "$env:COMPUTERNAME Robocopy encountered errors."
        TextBody    = "$($ErrorMessage): $ExitCode"
    }
    & "$PSScriptRoot\New-MailKitMessage.ps1" @MailParams
    exit 1
}