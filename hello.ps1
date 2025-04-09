# Load the Windows Forms assembly
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# First, display the Hello message box
[System.Windows.Forms.MessageBox]::Show("Hello", "Message", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)

# Ask for permission to take a screenshot
$permission = [System.Windows.Forms.MessageBox]::Show(
    "Would you like to take a screenshot of your screen?", 
    "Permission Request", 
    [System.Windows.Forms.MessageBoxButtons]::YesNo, 
    [System.Windows.Forms.MessageBoxIcon]::Question)

# Only take screenshot if user gives permission
if ($permission -eq [System.Windows.Forms.DialogResult]::Yes) {
    try {
        # Get screen bounds
        $bounds = [System.Windows.Forms.Screen]::PrimaryScreen.Bounds
        
        # Create a bitmap
        $bitmap = New-Object System.Drawing.Bitmap $bounds.Width, $bounds.Height
        
        # Create graphics
        $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
        
        # Copy screen to bitmap
        $graphics.CopyFromScreen($bounds.X, $bounds.Y, 0, 0, $bounds.Size)
        
        # Get downloads folder path
        $downloadsPath = [System.IO.Path]::Combine([System.Environment]::GetFolderPath([System.Environment+SpecialFolder]::UserProfile), "Downloads")
        
        # Create a filename with timestamp
        $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
        $filename = [System.IO.Path]::Combine($downloadsPath, "Screenshot_$timestamp.png")
        
        # Save the screenshot
        $bitmap.Save($filename, [System.Drawing.Imaging.ImageFormat]::Png)
        
        # Dispose of graphics and bitmap
        $graphics.Dispose()
        $bitmap.Dispose()
        
        # Notify the user that the screenshot has been saved
        [System.Windows.Forms.MessageBox]::Show(
            "Screenshot saved to:`n$filename", 
            "Screenshot Saved", 
            [System.Windows.Forms.MessageBoxButtons]::OK, 
            [System.Windows.Forms.MessageBoxIcon]::Information)
    }
    catch {
        # Show error message if something goes wrong
        [System.Windows.Forms.MessageBox]::Show(
            "Error taking screenshot: $_", 
            "Error", 
            [System.Windows.Forms.MessageBoxButtons]::OK, 
            [System.Windows.Forms.MessageBoxIcon]::Error)
    }
}
