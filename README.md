# Win11 Post Install PowerShell Script
A Windows 11 (24H2) Post Install Script in PowerShell to customize your working environment.

## Features
- Remove unwanted apps from installation $^{*}$
- Set Windows Explorer defaults $^{+}$
- Choose Performance Power Settings $^{+}$
- Enable Microsoft 365 Insiders Beta Channel for Office applications $^{+\#}$
- Update all remaining installed applications
- Update Windows with all current updates available
- Install from a list curated applications $^{*}$
- Create a bunch of Microsoft Edge Profiles for use with different clients $^{*}$
- Add additional folders to the environment PATH variable $^{*}$
- Update Taskbar icons $^{*}$
- Reboot if required

\* These are all easily customizable. Read notes below.<br>
\+ These can be disabled from the main script block section.<br>
\# You can either change the value to CurrentChannel or simply comment out this call in the main Script Block if you do not want to be part of the Microsoft 365 Insiders.

## References
The script utilizes ideas and code from many excellent scripts created by others while adding some new ones. Some of the other ones used are:
- Win11 Debloat: <https://github.com/Raphire/Win11Debloat>
- WinPostInstall: <https://github.com/jhx0/WinPostInstall>
- LetsDoAutomation: <https://github.com/letsdoautomation/powershell>

## Usage
1. Download the Powershell script from the repository.
2. (Optional) If you wish to edit it, I recommend using VS Code with the PowerShell extension. The script is divided into sections (using the "region" directive) that will make collapsing and navigating these sections easier.
3. Run the script in a PowerShell session as Administrator.
    - You will require to run `Set-ExecutionPolicy Unrestricted` first to be able to run this script.
4. When prompted at the end, you can decide to reboot or not. Script defaults to reboot after 30 seconds.
5. (Optional) Check the PostInstall.log file for any issues.

## Customization
### Unwanted Apps
The script uses a list of Application IDs from the comprehensive list available as part of Win11Debloat. You can change the list of apps to remove by referring to https://github.com/Raphire/Win11Debloat/blob/master/Appslist.txt.

Update the `$AppsToUninstall` variable in the "Lists" section with the ones you wish to uninstall.

### Explorer defaults
The script sets the following defaults for Windows/File Explorer:
- Show file extensions is Enabled
- Windows Taskbar is aligned to the Left
- The default Windows Chat (Teams Personal) is Disabled
- Start menu is set to show More Pinned Items (and less Recommendations)
- Clipboard History & Cloud Sync are Enabled
- Windows Theme is set to Dark
- The Search in Taskbar is set to Icon mode

Notes: 
1. Widgets are disabled and also turned off, but due to a change in Windows 11 24H2, this is done in a different function called `Remove-Widgets`.
2. You can comment out the ones you don't want to run by adding a `#` before those lines.

### Install Apps
You can install a number of apps each time you setup a new Windows PC by using Winget. You can retrieve the list of available Application IDs by:
- Using `winget list` in a Terminal window
- Going to https://winstall.app

Update the `$WingetAppList` variable in the "Lists" section with the ones you wish to install.

### Edge Profiles
You can quickly create a number of profiles for Microsoft Edge. This is useful if you're a consultant and work with many different clients. Keeping each client in their own profile makes it easy to keep their data separate.

To customize the profiles, there are 2 variables you can work with.

1. **$EdgeType** in the "Variables" section. This can be either "Edge" or "Edge Dev", depending on which version of the browser you want to use to create the profiles. 
    - Note: For Edge Dev to work, it must be one of the apps in the Install Apps list.
2. **$EdgeProfiles** in the "Lists" section. Add a list of client names you want to create profiles for using Edge. I prefer [TLAs](https://dictionary.cambridge.org/dictionary/english/tla) for each client, but you aren't restricted to them.

Each profile created will have the following features set:
- Name set as per the client name
- Random icon from the Edge profile icons list
- First run turned off

### Additional folders in PATH
If you need extra folders in the PATH Environment variable, simply add them as a list in the `$Paths` variable in the Lists section.

### Taskbar Icons
You can customize the icons pinned to the Taskbar. You can add a list of icons to be shown by editing the `$taskbar_custom` variable in the Lists section. 

To know how to customize this XML, read [Customize the Windows 11 Taskbar](https://learn.microsoft.com/en-us/windows-hardware/customize/desktop/customize-the-windows-11-taskbar). To get a list of Application IDs to use in the XML, run `Get-StartApps` in a Terminal Window as Administrator.

### TODO
The following are the things I wish to add to this script. 
- Clear Start Menu of all default pinned apps. This is possible to do via a binary file replacement as being done in Win11Debloat. However, I want to do this from within the script using commands and not a hack like that.
- Change the theme for each Edge profile that is created. I haven't found a way to do that yet.

 
