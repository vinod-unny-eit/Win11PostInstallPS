# Win11 Post Install PowerShell Script
A Windows 11 (24H2) Post Install Script in PowerShell to customize your working environment.

## Features
- Remove unwanted apps from installation $^{*}$
- Set Windows Explorer defaults $^{+}$
- Choose Performance Power Settings $^{+}$
- Enable Microsoft 365 Insiders Beta Channel for Office applications $^{+}$<sup>#</sup>
- Update all remaining installed applications
- Update Windows with all current updates available
- Install from a list curated applications $^{*}$
- Install custom applications from the internet and perform actions $^{*}$
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

Update the `$AppsToUninstall` variable in the "Variables" section with the ones you wish to uninstall.

### Explorer defaults
The script sets the following defaults for Windows/File Explorer:
- Show file extensions is Enabled
- Windows Taskbar is aligned to the Left
- The default Windows Chat (Teams Personal) is Disabled
- Start menu is set to show More Pinned Items (and less Recommendations)
- Clipboard History & Cloud Sync are Enabled
- Windows Theme is set to Dark
- The Search in Taskbar is set to Icon mode
- Moves all icons created by newly installed application off the Desktop and into an Applications folder under the current user's profile folder

Notes: 
1. Widgets are disabled and also turned off, but due to a change in Windows 11 24H2, this is done in a different function called `Remove-Widgets`.
2. You can comment out the ones you don't want to run by adding a `#` before those lines.

### Install Apps
You can install a number of apps each time you setup a new Windows PC by using Winget. You can retrieve the list of available Application IDs by:
- Using `winget list` in a Terminal window
- Going to https://winstall.app

Update the `$WingetAppList` variable in the "Variables" section with the ones you wish to install.

### Custom Installs
If there are some apps that you can't install via Winget, or they are simply portable apps that need to be downloaded and installed/unzipped locally, you can use the Custom Install section to do this.

To set this up, you need to add a new custom object into the array named `$CustomInstallArray`. The custom object has 5 parameters:
1. Name: The name of the application.
2. URL: The public URL from where the application can be downloaded.
3. Path: The absolute local path where the application should be downloaded.
4. Action: The action to take - This is a custom enum with the values `Ignore | Install | Unzip`.
5. PostInstall: A Post-install script in Powershell that can be executed automatically to move or clean up the install process.

#### Examples
`$CustomInstallArray += [CustomInstaller]::new("YT DLP", 'https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp.exe', 'c:\Portable\YT-DLP', [CustomInstallAction]::Ignore, $null)`
This downloads YT-DLP into the C:\Portable\YT-DLP folder (which is created if it doesn't exist) from the given URL, but doesn't do any installer or post-install actions.

`$CustomInstallArray += [CustomInstaller]::new('YT FFMpeg', 'https://github.com/yt-dlp/FFmpeg-Builds/releases/download/latest/ffmpeg-master-latest-win64-gpl.zip', 'c:\Portable\YT-DLP', [CustomInstallAction]::Unzip, 'mv ffmpeg-master*\bin\* c:\Portable\YT-DLP;Remove-Item ffmpeg-master* -Force -Recurse')`
This downloads the custom build of FFMPEG into the same folder and then unzips the archive as part of the install process. As part of the custom post-install, the files in the subdirectory "bin" are moved to the main folder and all the files and folders starting with "ffmpeg-master" are deleted.

There are a few more examples in the script as well.

### Edge Profiles
You can quickly create a number of profiles for Microsoft Edge. This is useful if you're a consultant and work with many different clients. Keeping each client in their own profile makes it easy to keep their data separate.

To customize the profiles, there are 2 variables you can work with.

1. **$EdgeType** in the "Variables" section. This can be either "Edge" or "Edge Dev", depending on which version of the browser you want to use to create the profiles. 
    - Note: For Edge Dev to work, it must be one of the apps in the Install Apps list.
2. **$EdgeProfiles** in the "Variables" section. Add a list of client names you want to create profiles for using Edge. I prefer [TLAs](https://dictionary.cambridge.org/dictionary/english/tla) for each client, but you aren't restricted to them.

Each profile created will have the following features set:
- Name set as per the client name
- Random icon from the Edge profile icons list
- First run turned off

### Additional folders in PATH
If you need extra folders in the PATH Environment variable, simply add them as a list in the `$Paths` variable in the Variables section.

### Taskbar Icons
You can customize the icons pinned to the Taskbar. You can add a list of icons to be shown by editing the `$taskbar_custom` variable in the Variables section. 

To know how to customize this XML, read [Customize the Windows 11 Taskbar](https://learn.microsoft.com/en-us/windows-hardware/customize/desktop/customize-the-windows-11-taskbar). To get a list of Application IDs to use in the XML, run `Get-StartApps` in a Terminal Window as Administrator.

## Change History
* Version 1.0, Nov 17, 2024
    - Initial Release
* Version 1.1, Nov 26, 2024
    - Added ability to perform custom application installs from EXE or ZIP. Useful for portable apps like Rufus, YT-DLP or SysInternals

## TODO
The following are the things I wish to add to this script. 
- Clear Start Menu of all default pinned apps. This is possible to do via a binary file replacement as being done in Win11Debloat. However, I want to do this from within the script using commands and not a hack like that.
- Change the theme for each Edge profile that is created. I haven't found a way to do that yet.

 
