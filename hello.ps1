# Load the Windows Forms and Drawing assemblies
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Display a single message box with greeting and permission request
$permission = [System.Windows.Forms.MessageBox]::Show(
    "Hello`n`nWould you like to take a screenshot of your screen?", # Combined message (use `n for newline)
    "Greeting and Permission Request",                             # Updated title
    [System.Windows.Forms.MessageBoxButtons]::YesNo,
    [System.Windows.Forms.MessageBoxIcon]::Question)

# Only take screenshot if user gives permission
if ($permission -eq [System.Windows.Forms.DialogResult]::Yes) {
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
        # Ensure width and height are positive
        if ($width -le 0 -or $height -le 0) {
             throw "Calculated screen dimensions are invalid (Width: $width, Height: $height). Ensure monitors are configured correctly."
        }
        $bitmap = New-Object System.Drawing.Bitmap $width, $height

        # Create graphics object from the bitmap
        $graphics = [System.Drawing.Graphics]::FromImage($bitmap)

        # Copy entire virtual screen to the bitmap
        $graphics.CopyFromScreen($left, $top, 0, 0, $bitmap.Size)

        # Get downloads folder path
        $downloadsPath = [System.IO.Path]::Combine([System.Environment]::GetFolderPath([System.Environment+SpecialFolder]::UserProfile), "Downloads")

        # Ensure Downloads directory exists
        if (-not (Test-Path $downloadsPath)) {
            New-Item -Path $downloadsPath -ItemType Directory -Force | Out-Null
        }

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
            "Error taking screenshot: $($_.Exception.Message)", # Display more specific error message
            "Error",
            [System.Windows.Forms.MessageBoxButtons]::OK,
            [System.Windows.Forms.MessageBoxIcon]::Error)
    }
}
# If the user clicked 'No', the script simply ends here.
