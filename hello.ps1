# Load the Windows Forms assembly
Add-Type -AssemblyName System.Windows.Forms

# Display a popup message box
[System.Windows.Forms.MessageBox]::Show("Hello", "Message", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
