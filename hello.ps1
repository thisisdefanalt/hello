

function Decode-Credential {
    param(
        [string]$EncodedCredential,
        [string]$Key = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789!@#$%^&*()_+-=[]{}|;:,.<>?"
    )
    
    try {
       
        $decodedBytes = [System.Convert]::FromBase64String($EncodedCredential)
        $decodedText = [System.Text.Encoding]::UTF8.GetString($decodedBytes)
        
       
        $decryptedText = ""
        for ($i = 0; $i -lt $decodedText.Length; $i++) {
            $decryptedText += [char]([int]$decodedText[$i] -bxor [int]$Key[$i % $Key.Length])
        }
        
        return $decryptedText
    }
    catch {
        Write-Error "Decryption failed: $_"
        return $null
    }
}


$encodedBotToken = "DBYOdQoSEnoHDiA7ADQkKRwWHiMaEgJpFz1PJTUiUQcLRjg+RjojKg0hFRgLIzlbTy8mTVIBYQcBVHpNbXtlCEJOEWsSZHpe"
$encodedChannelId = "cHF2fXBwc35xeXl4dHt3ZmJqYg=="
$encodedClientSecret = "d3oUdDQJAnl8fCUlNWM8GzkdFREsEwUiD2omDzMnNiI="


$botToken = Decode-Credential -EncodedCredential $encodedBotToken
$channelId = Decode-Credential -EncodedCredential $encodedChannelId
$clientSecret = Decode-Credential -EncodedCredential $encodedClientSecret

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
