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
        # Get all screens
        $screens = [System.Windows.Forms.Screen]::AllScreens
        $screenCount = $screens.Length
        
        # Get downloads folder path
        $downloadsPath = [System.IO.Path]::Combine([System.Environment]::GetFolderPath([System.Environment+SpecialFolder]::UserProfile), "Downloads")
        
        # Create a timestamp for the filenames
        $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
        
        # Initialize an array to store all screenshot filenames
        $screenshotFiles = @()
        
        # Take a screenshot of each screen
        for ($i = 0; $i -lt $screenCount; $i++) {
            $screen = $screens[$i]
            $bounds = $screen.Bounds
            
            # Create a bitmap
            $bitmap = New-Object System.Drawing.Bitmap $bounds.Width, $bounds.Height
            
            # Create graphics
            $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
            
            # Copy screen to bitmap
            $graphics.CopyFromScreen($bounds.X, $bounds.Y, 0, 0, $bounds.Size)
            
            # Create a filename with timestamp and screen number
            $screenNumber = $i + 1
            $filename = [System.IO.Path]::Combine($downloadsPath, "Screenshot_${timestamp}_Monitor${screenNumber}of${screenCount}.png")
            
            # Save the screenshot
            $bitmap.Save($filename, [System.Drawing.Imaging.ImageFormat]::Png)
            
            # Add the filename to our array
            $screenshotFiles += $filename
            
            # Dispose of graphics and bitmap
            $graphics.Dispose()
            $bitmap.Dispose()
        }
        
        # Create a message with all saved files
        $fileListMessage = "Screenshots saved to:`n" + ($screenshotFiles -join "`n")
        
        # Notify the user that the screenshots have been saved
        [System.Windows.Forms.MessageBox]::Show(
            $fileListMessage, 
            "Screenshots Saved", 
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
