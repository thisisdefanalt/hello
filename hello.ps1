# Discord Bot Online Message Sender

# Requires Discord.Net libraries to be present
Add-Type -Path ".\Discord.Net.Core.dll"
Add-Type -Path ".\Discord.Net.WebSocket.dll"
Add-Type -Path ".\Discord.Net.Rest.dll"
Add-Type -Path ".\System.Collections.Immutable.dll"
Add-Type -AssemblyName System.Windows.Forms

# Configuration
$botToken = "MTM5NTY0OTAzOTIwMzA4NTU2.GVF4al.QT-VNDbQdjxWL-8W_7b0S45aLzUBDHaj454NRw"
$channelId = 1359564683249586381

# Create Discord Client Configuration
$config = New-Object Discord.WebSocket.DiscordSocketConfig
$config.LogLevel = [Discord.LogSeverity]::Warning
$client = New-Object Discord.WebSocket.DiscordSocketClient($config)

# Logging function
$logAction = {
    param($msg)
    Write-Host $msg.ToString()
}
$client.Add_Log($logAction)

# Ready event handler
$readyAction = {
    Write-Host "Bot is now online!"
    
    # Show popup
    [System.Windows.Forms.MessageBox]::Show("Hello!", "Greeting", 
        [System.Windows.Forms.MessageBoxButtons]::OK, 
        [System.Windows.Forms.MessageBoxIcon]::Information)

    # Get the channel and send message
    $channel = $client.GetChannel($channelId)
    $sendTask = $channel.SendMessageAsync("Hello from PowerShell script!")
    $sendTask.Wait()

    Write-Host "Message sent successfully!"

    # Disconnect after sending message
    $stopTask = $client.StopAsync()
    $stopTask.Wait()

    $logoutTask = $client.LogoutAsync()
    $logoutTask.Wait()

    # Exit the script
    [Environment]::Exit(0)
}

# Hook up the ready event
$client.Add_Ready($readyAction)

try {
    # Login and start the client
    $loginTask = $client.LoginAsync([Discord.TokenType]::Bot, $botToken)
    $loginTask.Wait()

    $startTask = $client.StartAsync()
    $startTask.Wait()

    # Keep the script running
    Start-Sleep -Seconds 300  # 5-minute timeout in case something goes wrong
}
catch {
    Write-Host "An error occurred: $_"
    
    # Log error to desktop
    $errorLogPath = Join-Path -Path ([Environment]::GetFolderPath('Desktop')) -ChildPath "discord_bot_error.log"
    $errorDetails = @"
[$(Get-Date)]
Error: $($_.Exception.Message)
Full Error: $($_.Exception | Format-List * -Force | Out-String)
"@
    Add-Content -Path $errorLogPath -Value $errorDetails
}
finally {
    # Ensure client is stopped and logged out if not already done
    if ($client.ConnectionState -ne [Discord.ConnectionState]::Disconnected) {
        $stopTask = $client.StopAsync()
        $stopTask.Wait()

        $logoutTask = $client.LogoutAsync()
        $logoutTask.Wait()
    }
}
