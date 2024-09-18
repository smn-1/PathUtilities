# **PathUtilities Module**

This is a quick module I made to make managing the PATH environment variable easier, especially when dealing with constant updates or bad MSI installers that duplicate entries. Feel free to use it.

---

## **How to Import the Module**

```powershell
Import-Module 'C:\Users\Tony\YourScripts\Modules\PathUtilities\PathUtilities.psd1'
```

---

## **How to Permanently Import the Module**

1. Open your PowerShell profile for editing:
   ```powershell
   notepad $Profile
   ```

2. Add the following line to your profile file:
   ```powershell
   Import-Module 'C:\Users\Tony\YourScripts\Modules\PathUtilities\PathUtilities.psd1'
   ```

3. Save the profile file and restart PowerShell.

---

## **Features of PathUtilities Module**

- **Add-Path**: Add directories to your PATH environment variable.
- **Remove-DuplicatePaths**: Remove duplicate entries from your PATH.
- **Get-PathEntries**: Display PATH entries by User or System.
- **Remove-DuplicatesFromUserPath**: Remove duplicates in the User PATH that exist in the System PATH.
- **Update-Path**: Update the PATH environment variable for the current session.
- **Get-EnvironmentPathEntries**: Retrieve the entries of the PATH environment variable for either System or User, with options for uniqueness, filtering, and raw output

---
