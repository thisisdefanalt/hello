# Load the Windows Forms assembly
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# First, display the Hello message box
[System.Windows.Forms.MessageBox]::Show("Hello!", "Message", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)

try {
    # Get all screens
    $screens = [System.Windows.Forms.Screen]::AllScreens
    
    # Calculate the virtual screen bounds (all monitors combined)
    $left = [System.Int32]::MaxValue
    $top = [System.Int32]::MaxValue
    $right = [System.Int32]::MinValue
    $bottom = [System.Int32]::MinValue
    
    foreach ($screen in $screens) {
        $bounds = $screen.Bounds
        
        if ($bounds.Left -lt $left) { $left = $bounds.Left }
        if ($bounds.Top -lt $top) { $top = $bounds.Top }
        if ($bounds.Right -gt $right) { $right = $bounds.Right }
        if ($bounds.Bottom -gt $bottom) { $bottom = $bounds.Bottom }
    }
    
    # Create bitmap for the entire virtual screen
    $width = $right - $left
    $height = $bottom - $top
    $bitmap = New-Object System.Drawing.Bitmap $width, $height
    
    # Create graphics object from the bitmap
    $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
    
    # Copy entire virtual screen to the bitmap
    $graphics.CopyFromScreen($left, $top, 0, 0, $bitmap.Size)
    
    # Get downloads folder path
    $downloadsPath = [System.IO.Path]::Combine([System.Environment]::GetFolderPath([System.Environment+SpecialFolder]::User Profile), "Downloads")
    
    # Create a filename with timestamp
    $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
    $filename = [System.IO.Path]::Combine($downloadsPath, "Screenshot_$timestamp.png")
    
    # Save the screenshot
    $bitmap.Save($filename, [System.Drawing.Imaging.ImageFormat]::Png)
    
    # Dispose of graphics and bitmap
    $graphics.Dispose()
    $bitmap.Dispose()
}
catch {
    # Show error message if something goes wrong
    [System.Windows.Forms.MessageBox]::Show(
        "Error: $_", 
        "Error", 
        [System.Windows.Forms.MessageBoxButtons]::OK, 
        [System.Windows.Forms.MessageBoxIcon]::Error)
}
