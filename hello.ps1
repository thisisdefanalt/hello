# Discord Bot Popup Messenger with Detailed Error Handling

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
            -Body $body `
            -ErrorVariable RestError
        
        return $true
    }
    catch {
        # Capture detailed error information
        $fullError = $_.Exception.Response
        $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
        $reader.BaseStream.Position = 0
        $reader.DiscardBufferedData()
        $errorBody = $reader.ReadToEnd()
        
        # Log detailed error information
        Write-Host "Full Error Details:"
        Write-Host "Error Response: $fullError"
        Write-Host "Error Body: $errorBody"
        Write-Host "Exception Message: $($_.Exception.Message)"
        
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
            $wshell.Popup("Failed to send message to Discord. Check console for details.", 0, "Error", 16)
        }
    }
    catch {
        $wshell.Popup("An unexpected error occurred: $($_.Exception.Message)", 0, "Error", 16)
    }
}
