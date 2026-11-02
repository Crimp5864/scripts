#Requires -Modules Send-MailkitMessage

param (
[string]$Subject,
[string]$TextBody
)

Import-Module -Name Send-MailKitMessage

# Required variables
# SMTP server ([string])
$SMTPServer = "smtp.gmail.com"
# Port ([int])
$Port = 587
# Sender ([MimeKit.MailboxAddress] http://www.mimekit.net/docs/html/T_MimeKit_MailboxAddress.htm)
$From = [MimeKit.MailboxAddress]"<email address>"
# Recipient list ([MimeKit.InternetAddressList] http://www.mimekit.net/docs/html/T_MimeKit_InternetAddressList.htm)
$RecipientList = [MimeKit.InternetAddressList]::new()
$RecipientList.Add([MimeKit.InternetAddress]"<email address>")

# Optional variables
# Use secure connection if available ([bool])
$UseSecureConnectionIfAvailable = $true

# Store new credential
#Get-Credential | Export-Clixml -Path $env:USERPROFILE\OneDrive\Documents\PowerShell\Secrets\mailkit-$env:COMPUTERNAME.credential

# Authentication ([System.Management.Automation.PSCredential])
#$Credential = [System.Management.Automation.PSCredential]::new("<email address>", (ConvertTo-SecureString -String <app password> -AsPlainText -Force))
$Credential = Import-Clixml "$env:USERPROFILE\Documents\PowerShell\Secrets\mailkit-$env:COMPUTERNAME.credential"

# CC list ([MimeKit.InternetAddressList] http://www.mimekit.net/docs/html/T_MimeKit_InternetAddressList.htm)
#$CCList = [MimeKit.InternetAddressList]::new()
#$CCList.Add([MimeKit.InternetAddress]"CCRecipient1EmailAddress")

# BCC list ([MimeKit.InternetAddressList] http://www.mimekit.net/docs/html/T_MimeKit_InternetAddressList.htm)
#$BCCList = [MimeKit.InternetAddressList]::new()
#$BCCList.Add([MimeKit.InternetAddress]"BCCRecipient1EmailAddress")

# HTML body ([string])
#$HTMLBody = [string]"HTMLBody"

# Attachment list ([System.Collections.Generic.List[string]])
#$AttachmentList = [System.Collections.Generic.List[string]]::new()
#$AttachmentList.Add("Attachment1FilePath")

# Splat parameters
$Parameters = @{
    "UseSecureConnectionIfAvailable" = $UseSecureConnectionIfAvailable    
    "Credential" = $Credential
    "SMTPServer" = $SMTPServer
    "Port" = $Port
    "From" = $From
    "RecipientList" = $RecipientList
    #"CCList" = $CCList
    #"BCCList" = $BCCList
    "Subject" = $Subject
    "TextBody" = $TextBody
    #"HTMLBody" = $HTMLBody
    #"AttachmentList" = $AttachmentList
}

# Send message
Send-MailKitMessage @Parameters
