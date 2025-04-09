# Load the Windows Forms assembly
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Function to log messages
function Log-Message {
    param (
        [string]$message
    )
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Write-Host "$timestamp - $message"
}

# First, display the Hello message box
Log-Message "Displaying Hello message box."
[System.Windows.Forms.MessageBox]::Show("Hello!", "Message", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)

try {
    Log-Message "Attempting to capture the screen."
    # Get all screens
    $screens = [System.Windows.Forms.Screen]::AllScreens
    Log-Message "Number of screens detected: $($screens.Count)"

    # Calculate the virtual screen bounds (all monitors combined)
    $left = [System.Int32]::MaxValue
    $top = [System.Int32]::MaxValue
    $right = [System.Int32]::MinValue
    $bottom = [System.Int32]::MinValue

    foreach ($screen in $screens) {
        $bounds = $screen.Bounds
        Log-Message "Screen bounds: Left=$($bounds.Left), Top=$($bounds.Top), Right=$($bounds.Right), Bottom=$($bounds.Bottom)"
        if ($bounds.Left -lt $left) { $left = $bounds.Left }
        if ($bounds.Top -lt $top) { $top = $bounds.Top }
        if ($bounds.Right -gt $right) { $right = $bounds.Right }
        if ($bounds.Bottom -gt $bottom) { $bottom = $bounds.Bottom }
    }

    # Create bitmap for the entire virtual screen
    $width = $right - $left
    $height = $bottom - $top
    Log-Message "Virtual screen dimensions: Width=$width, Height=$height"

    $bitmap = New-Object System.Drawing.Bitmap $width, $height
    
    # Create graphics object from the bitmap
    $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
    
    # Copy entire virtual screen to the bitmap
    Log-Message "Copying screen to bitmap."
    $graphics.CopyFromScreen($left, $top, 0, 0, $bitmap.Size)

    # Get downloads folder path (corrected)
    $downloadsPath = [System.Environment]::GetFolderPath([System.Environment+SpecialFolder]::UserProfile)
    $downloadsPath = Join-Path -Path $downloadsPath -ChildPath "Downloads"
    
    Log-Message "Downloads folder path: $downloadsPath"

    # Create a filename with timestamp
    $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
    $filename = Join-Path -Path $downloadsPath -ChildPath "Screenshot_$timestamp.png"
    
    Log-Message "Saving screenshot to: $filename"

    # Save the screenshot
    $bitmap.Save($filename, [System.Drawing.Imaging.ImageFormat]::Png)

    # Dispose of graphics and bitmap
    $graphics.Dispose()
    $bitmap.Dispose()

    Log-Message "Screenshot saved successfully."
}
catch {
    # Show error message if something goes wrong
    Log-Message "An error occurred: $_"
    [System.Windows.Forms.MessageBox]::Show(
        "Error: $_", 
        "Error", 
        [System.Windows.Forms.MessageBoxButtons]::OK, 
        [System.Windows.Forms.MessageBoxIcon]::Error)
}

# Wait for user input before closing
Read-Host -Prompt "Press Enter to exit"
