# Discord Bot Popup Messenger Script

# Configuration
$botToken = "MTM5NTY0OTAzOTIwMzA4NTU2.GVF4al.QT-VNDbQdjxWL-8W_7b0S45aLzUBDHaj454NRw"
$channelId = "1359564683249586381"

# Function to send message using Discord Bot API
function Send-DiscordMessage {
    param (
        [string]$Token,
        [string]$ChannelId,
        [string]$Message
    )
    $headers = @{
        "Authorization" = "Bot $Token"
        "Content-Type" = "application/json"
    }
    $body = @{
        content = $Message
    } | ConvertTo-Json
    try {
        $response = Invoke-RestMethod -Uri "https://discord.com/api/v10/channels/$ChannelId/messages" `
            -Method Post `
            -Headers $headers `
            -Body $body
        return $true
    }
    catch {
        Write-Host "Error sending message: $_"
        return $false
    }
}

# Show Hello popup
$wshell = New-Object -ComObject Wscript.Shell
$result = $wshell.Popup("Hello!", 0, "Greeting", 0)

# If user clicks OK (result = 1), send message to Discord
if ($result -eq 1) {
    try {
        $messageSent = Send-DiscordMessage -Token $botToken -ChannelId $channelId -Message "Hello from PowerShell script!"
        
        if ($messageSent) {
            $wshell.Popup("Message sent to Discord successfully!", 0, "Success", 0)
        }
        else {
            $wshell.Popup("Failed to send message to Discord.", 0, "Error", 16)
        }
    }
    catch {
        $wshell.Popup("An error occurred: $($_.Exception.Message)", 0, "Error", 16)
    }
}
