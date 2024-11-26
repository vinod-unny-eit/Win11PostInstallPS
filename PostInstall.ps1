#region References
#### Win11 Debloat: https://github.com/Raphire/Win11Debloat
#### WinPostInstall: https://github.com/jhx0/WinPostInstall
#### LetsDoAutomation: https://github.com/letsdoautomation/powershell
#endregion References

#region Constants
$WinVersion = Get-ItemPropertyValue 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion' CurrentBuild
$Version = "1.1"
$Logo = @"
###################################
          Vinod's Windows 
			
        Post Install Script
		
 Version: $Version
###################################
"@
$LogFile = "PostInstall.log"
$LogPath = (Get-Location).Path + "\" + $LogFile
# Types of install actions for custom installers
enum CustomInstallAction {
	Ignore		# Simply downloads the provided file
	Install		# Runs the file if a .EXE
	Unzip		# Unzips the file if a .ZIP
}
# Custom class with constructor to quickly define custom installers
class CustomInstaller {
	[string]$Name
	[string]$Url
	[string]$Path
	[CustomInstallAction]$Action
	[string]$PostInstallScript

	CustomInstaller([string]$prop1, [string]$prop2, [string]$prop3, [CustomInstallAction]$prop4, [string]$prop5) {
		$this.Name = $prop1
		$this.Url = $prop2
		$this.Path = $prop3
		$this.Action = $prop4
		$this.PostInstallScript = $prop5
	}
}
# Initializing the array for custom installers
$CustomInstallArray = @()
#endregion Constants

#region Variables
$EdgeType = "Edge Dev"		# Use 'Edge' or 'Edge Dev' depending on which you wish to use as primary

# Edge Profiles to create. The 'Default' profile will be created anyway which can be used as your Personal account.
$EdgeProfiles = @(
	"EIT",
	"KNS",
	"JSA",
	"CDP",
	"EDI",
	"GFI"
)

# Apps to install. Get App IDs by running 'winget list' or visiting 'https://winstall.app'.
$WingetAppList = @(
	"ShareX.ShareX",
	"OpenWhisperSystems.Signal",
	"9NBDXK71NK08", #WhatsApp Beta
	"Calibre.Calibre",
	"Foxit.FoxitReader",
	"Microsoft.Edge.Dev",
	"Microsoft.Office",
	"Nvidia.GeForceExperience",
	"agalwood.Motrix",
	"mRemoteNG.mRemoteNG",
	"Microsoft.PowerToys",
	"Microsoft.SQLServerManagementStudio",
	"dotPDN.PaintDotNet",
	"Logitech.GHUB",
	"RARLab.WinRAR",
	"Daum.PotPlayer",
	"OpenVPNTechnologies.OpenVPN"
)

# Apps to uninstall. Get App IDs from Raphire's *excellent* Win11Debloat list 'https://github.com/Raphire/Win11Debloat/blob/master/Appslist.txt'
$AppsToUninstall = @(
	"Microsoft.3DBuilder",
	"Microsoft.549981C3F5F10",
	"Microsoft.BingFinance",
	"Microsoft.BingFoodAndDrink",
	"Microsoft.BingHealthAndFitness",
	"Microsoft.BingNews",
	"Microsoft.BingSports",
	"Microsoft.BingTranslator",
	"Microsoft.BingTravel ",
	"Microsoft.BingWeather",
	"Microsoft.Messaging",
	"Microsoft.Microsoft3DViewer",
	"Microsoft.MicrosoftJournal",
	"Microsoft.MicrosoftOfficeHub",
	"Microsoft.MicrosoftSolitaireCollection",
	"Microsoft.MixedReality.Portal",
	"Microsoft.NetworkSpeedTest",
	"Microsoft.News",
	"Microsoft.Office.Sway",
	"Microsoft.OneConnect",
	"Microsoft.Print3D",
	"Microsoft.SkypeApp",
	"Microsoft.WindowsMaps",
	"Microsoft.WindowsSoundRecorder",
	"Microsoft.XboxApp",
	"Microsoft.ZuneVideo",
	"MicrosoftCorporationII.MicrosoftFamily",
	"MicrosoftCorporationII.QuickAssist",
	"MicrosoftTeams",
	"ACGMediaPlayer",
	"ActiproSoftwareLLC",
	"AdobeSystemsIncorporated.AdobePhotoshopExpress",
	"Amazon.com.Amazon",
	"AmazonVideo.PrimeVideo",
	"Asphalt8Airborne ",
	"AutodeskSketchBook",
	"CaesarsSlotsFreeCasino",
	"COOKINGFEVER",
	"CyberLinkMediaSuiteEssentials",
	"DisneyMagicKingdoms",
	"Disney",
	"DrawboardPDF",
	"Duolingo-LearnLanguagesforFree",
	"EclipseManager",
	"Facebook",
	"FarmVille2CountryEscape",
	"fitbit",
	"Flipboard",
	"HiddenCity",
	"HULULLC.HULUPLUS",
	"iHeartRadio",
	"Instagram",
	"king.com.BubbleWitch3Saga",
	"king.com.CandyCrushSaga",
	"king.com.CandyCrushSodaSaga",
	"LinkedInforWindows",
	"MarchofEmpires",
	"Netflix",
	"NYTCrossword",
	"OneCalendar",
	"PandoraMediaInc",
	"PhototasticCollage",
	"PicsArt-PhotoStudio",
	"Plex",
	"PolarrPhotoEditorAcademicEdition",
	"Royal Revolt",
	"Shazam",
	"Sidia.LiveWallpaper",
	"SlingTV",
	"Spotify",
	"TikTok",
	"TuneInRadio",
	"Twitter",
	"Viber",
	"WinZipUniversal",
	"Wunderlist",
	"XING",
	"Microsoft.MSPaint",
	"Microsoft.People",
	"Microsoft.windowscommunicationsapps"
)

# Specify a set of custom installs to do that are not covered by winget. Each line in the array is a single install. Format/Order of parameters are:
# Name of app, URL to download from, Local folder path (will be created), Install, Unzip or Ignore
$CustomInstallArray += [CustomInstaller]::new("YT DLP", 'https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp.exe', 'D:\Portable\YT-DLP', [CustomInstallAction]::Ignore, $null)
$CustomInstallArray += [CustomInstaller]::new('YT FFMpeg', 'https://github.com/yt-dlp/FFmpeg-Builds/releases/download/latest/ffmpeg-master-latest-win64-gpl.zip', 
	'd:\Portable\YT-DLP', [CustomInstallAction]::Unzip, 'mv ffmpeg-master*\bin\* d:\Portable\YT-DLP;Remove-Item ffmpeg-master* -Force -Recurse')
$CustomInstallArray += [CustomInstaller]::new("Rufus", 'https://github.com/pbatard/rufus/releases/download/v4.6/rufus-4.6.exe', 'd:\Portable\', [CustomInstallAction]::Ignore, $null)
$CustomInstallArray += [CustomInstaller]::new("Handbrake", 'https://github.com/HandBrake/HandBrake/releases/download/1.8.2/HandBrake-1.8.2-x86_64-Win_GUI.zip', 
	'd:\Portable\Handbrake', [CustomInstallAction]::Unzip, 'mv d:\Portable\Handbrake\Handbrake\* d:\Portable\Handbrake;Remove-Item d:\Portable\Handbrake\Handbrake -force -recurse;Remove-Item D:\Portable\Handbrake\*.zip -force')
$CustomInstallArray += [CustomInstaller]::new("Zoomit", 'https://download.sysinternals.com/files/ZoomIt.zip', 'd:\Portable\Sysinternals', [CustomInstallAction]::Unzip, $null)
$CustomInstallArray += [CustomInstaller]::new("Procmon", 'https://download.sysinternals.com/files/ProcessExplorer.zip', 
	'd:\Portable\Sysinternals', [CustomInstallAction]::Unzip, "Remove-Item d:\Portable\SysInternals\*.zip -Force")

# App Paths to add
$Paths = @(
	"D:\Portable"
)

$taskbar_clear = @"
<?xml version="1.0" encoding="utf-8"?>
<LayoutModificationTemplate
	xmlns="http://schemas.microsoft.com/Start/2014/LayoutModification"
	xmlns:defaultlayout="http://schemas.microsoft.com/Start/2014/FullDefaultLayout"
	xmlns:start="http://schemas.microsoft.com/Start/2014/StartLayout"
	xmlns:taskbar="http://schemas.microsoft.com/Start/2014/TaskbarLayout"
	Version="1">
<CustomTaskbarLayoutCollection PinListPlacement="Replace">
	<defaultlayout:TaskbarLayout>
	<taskbar:TaskbarPinList>
		<taskbar:DesktopApp DesktopApplicationLinkPath="#leaveempty"/>
	</taskbar:TaskbarPinList>
	</defaultlayout:TaskbarLayout>
</CustomTaskbarLayoutCollection>
</LayoutModificationTemplate>
"@

$taskbar_custom = @"
<?xml version="1.0" encoding="utf-8"?>
<LayoutModificationTemplate
	xmlns="http://schemas.microsoft.com/Start/2014/LayoutModification"
	xmlns:defaultlayout="http://schemas.microsoft.com/Start/2014/FullDefaultLayout"
	xmlns:start="http://schemas.microsoft.com/Start/2014/StartLayout"
	xmlns:taskbar="http://schemas.microsoft.com/Start/2014/TaskbarLayout"
	Version="1">
<CustomTaskbarLayoutCollection PinListPlacement="Replace">
	<defaultlayout:TaskbarLayout>
	<taskbar:TaskbarPinList>
		<taskbar:DesktopApp DesktopApplicationID="MSEdgeDev" />
		<taskbar:DesktopApp DesktopApplicationID="Microsoft.Office.OUTLOOK.EXE.15" />
		<taskbar:DesktopApp DesktopApplicationID="Microsoft.Windows.Explorer" />
		<taskbar:DesktopApp DesktopApplicationLinkPath="%APPDATA%\Programs\Motrix\Motrix.exe" />
		<taskbar:DesktopApp DesktopApplicationID="Microsoft.Office.ONENOTE.EXE.15" />
		<taskbar:DesktopApp DesktopApplicationID="Microsoft.Office.EXCEL.EXE.15" />
		<taskbar:DesktopApp DesktopApplicationID="MSTeams_8wekyb3d8bbwe!MSTeams" />
		<taskbar:DesktopApp DesktopApplicationID="Microsoft.OutlookForWindows_8wekyb3d8bbwe!Microsoft.OutlookforWindows" />
		<taskbar:DesktopApp DesktopApplicationID="Microsoft.YourPhone_8wekyb3d8bbwe!App" />
	</taskbar:TaskbarPinList>
	</defaultlayout:TaskbarLayout>
</CustomTaskbarLayoutCollection>
</LayoutModificationTemplate>
"@
#endregion Variables

#region Functions

# Write to installation log file
function Write-Log {
	param (
		$Message
	)
	
	$Time = Get-Date -Format "dd/MM/yyyy - HH:mm"

	Write-Output "[$Time] [INFO] $Message" | Tee-Object -Append -FilePath $LogPath
}

# Check if currently running as admin
function Run-AsAdmin {
	$currentUser = New-Object Security.Principal.WindowsPrincipal $([Security.Principal.WindowsIdentity]::GetCurrent())
	$IsAdmin = $currentUser.IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)

	if ($IsAdmin -eq $false) {
		Write-Host "[ERROR] You need admin rights to run some of the functions - Exiting!"
		exit
	}
}

# Define a function to extract the filename from a URL
function Get-FilenameFromURL {
    param (
        [string]$url
    )

    # Use [System.Uri] class to parse the URL
    $uri = [System.Uri]::new($url)

    # Extract the filename
    $filename = ""

    # Check if the URL contains query parameters
    if ($uri.Query) {
        # Use regular expression to find the value of 'file' parameter
        $regex = [regex]::new("file=([^&]+)")
        $match = $regex.Match($uri.Query)
        if ($match.Success) {
            $filename = $match.Groups[1].Value
        }
    }
    
    # If no query parameters, check the path segment
    if (-not $filename) {
        $filename = [System.IO.Path]::GetFileName($uri.AbsolutePath)
    }

    # Return the filename if found
    if ($filename) {
        return $filename
    } else {
        return "Filename not found."
    }
}

# Needed to get the Windows Update PS Module
function Install-NuGET {
	Install-PackageProvider -Name NuGet -Force
}

# Install all Windows Updates
function Install-WindowsUpdates {
	Write-Log "Running Windows Update"
	
	# Windows Update PS Module
	Install-Module -Name PSWindowsUpdate -Force

	# Get all Updates
	Get-WindowsUpdate -Confirm -AcceptAll

	# Do all upgrades
	Install-WindowsUpdate -MicrosoftUpdate -AcceptAll -Confirm -IgnoreReboot
}

# Update Power Settings
function Set-PowerSettings {
	Write-Log "Tweaking Power Management"

	# Set High Performance profile
	powercfg.exe /setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c
    
	# Disable hibernate timeout
	powercfg.exe /change hibernate-timeout-ac 0
	powercfg.exe /change hibernate-timeout-dc 0

	# Disable hibernate
	powercfg.exe /hibernate off
}

# Install app updates via Winget
function Install-winget-Updates {
	Write-Log "Updating via winget"

	# Upgrade everything
	winget upgrade --all --force --accept-package-agreements --accept-source-agreements
}

# Install Winget Applications
function Install-WingetApplications {
	foreach ($app in $WingetAppList) {
		Write-Log "Installing $app from Winget..."
		winget install --accept-package-agreements --accept-source-agreements --id $app
	}
}

# Add extra paths to Enivornment variable
function Alter-PathVariable {
	Write-Log "Adding PATH entries"
	
	foreach ($path in $Paths) {
		$CurrentPATH = ([Environment]::GetEnvironmentVariable("PATH", 1)).Split(";")

		if ($CurrentPATH.Contains($path)) {
			continue
		}

		$NewPATH = ($CurrentPATH + $Path) -Join ";"
		Write-Host $NewPATH
		[Environment]::SetEnvironmentVariable("PATH", $NewPATH, [EnvironmentVariableTarget]::User) 
	}
}

# Reboot
function Restart-System {
	Write-Log "Rebooting"
	
	Restart-Computer
}

# Set defaults for Windows Explorer
function Set-ExplorerDefaults {
	Write-Log "Showing known file extensions..."
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "HideFileExt" -Type DWord -Value 0

	Write-Log "Aligning Taskbar to left..."
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "TaskbarAl" -Type DWord -Value 0

	Write-Log "Disabling Chat..."
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "TaskbarMn" -Type DWord -Value 0

	Write-Log "Setting Start to show more Pinned Apps..."
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name Start_Layout -Type Dword -Value 1

	Write-Log "Enabling Clipboard History..."
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\Clipboard" -Name "EnableCloudClipboard" -Type Dword -Value 1
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\Clipboard" -Name "CloudClipboardAutomaticUpload" -Type Dword -Value 1

	## Widget Registry Keys are now restricted in Win11 24H2. Moved to Remove-Widgets function instead.
	#Write-Log "Hiding Widgets..."
	#Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "TaskbarDa" -Type DWord -Value 0

	#Write-Log "Disabling Widgets Service..."
	#Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\PolicyManager\default\NewsAndInterests\AllowNewsAndInterests" -Name "value" -Type DWord -Value 0

	Write-Log "Setting Dark Theme..."
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name "AppsUseLightTheme" -Type DWord -Value 0
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name "SystemUsesLightTheme" -Type DWord -Value 0

	Write-Log "Setting Taskbar Search to Icon..."
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search" -Name "SearchboxTaskbarMode" -Type DWord -Value 1
}

# Set registry key to enable Microsoft 365 Office Insider Beta Channel
function Set-M365Insider {
	Write-Log "Adding Microsoft 365 Insider Beta Channel Registry Entry..."
	$command = 'reg add HKLM\Software\Policies\Microsoft\office\16.0\common\officeupdate /v updatebranch /t REG_SZ /d BetaChannel /f'
	Start-Process cmd.exe -ArgumentList "/c $command" -NoNewWindow -Wait
}

# Remove apps installed by default
function Remove-Apps {
	# Loop through each app in the list
	Foreach ($app in $AppsToUninstall) { 
		Write-Log "Attempting to remove $app..."

		# Use Remove-AppxPackage to remove all other apps
		$app = '*' + $app + '*'

		# Remove installed app for all existing users
		if ($WinVersion -ge 22000) {
			# Windows 11 build 22000 or later
			try {
				Get-AppxPackage -Name $app -AllUsers | Remove-AppxPackage -AllUsers -ErrorAction Continue
				Write-Log "...Removed $app for all users" -ForegroundColor DarkGray
			}
			catch {
				Write-Log "...Unable to remove $app for all users" 
				Write-Log $psitem.Exception.StackTrace
			}
			
			# Try removing the app from the provisioned package so that other new users will not get them either
			try {
				Get-AppxProvisionedPackage -Online | Where-Object { $_.PackageName -like $app } | ForEach-Object { Remove-ProvisionedAppxPackage -Online -AllUsers -PackageName $_.PackageName }
			}
			catch {
				Write-Log "...Unable to remove $app from windows image" 
				Write-Log $psitem.Exception.StackTrace
			}
		}
	}
            
	Write-Output ""
}

# Create Edge Profiles and customize them
function Create-EdgeProfiles {
	
	# Let's disable the First-Run wizard that will appear for each profile
	$command = 'reg add HKLM\SOFTWARE\Policies\Microsoft\Edge /v HideFirstRunExperience /t REG_DWORD /d 1 /f'
	Start-Process cmd.exe -ArgumentList "/c $command" -NoNewWindow -Wait

	$avatar_index = 0
	$avatar_array = @('22', '24', '26', '28', '30', '32', '34', '36', '38')

	foreach ($profile in $EdgeProfiles) {
		# Create a profile path for this profile
		$profilePath = "profile-" + $profile.replace(' ', '-')
		Write-Log "Creating Edge profile for $profile in path $profilePath..."

		# Create the profile
		$proc = Start-Process -FilePath "C:\Program Files (x86)\Microsoft\$EdgeType\Application\msedge.exe" -ArgumentList "--profile-directory=$profilePath --no-first-run --no-default-browser-check --flag-switches-begin --flag-switches-end --site-per-process" -PassThru

		Write-Output "Profile $profile created, wait 15 seconds before closing Edge"

		Start-Sleep -Seconds 15 #it takes roughly 15 seconds to prepare the profile and write all files to disk.
		Stop-Process -Name "msedge"

		# Customize Profile name for this profile. See https://www.cloudappie.nl/improved-edge-profiles-powershell/

		# Edit profile name
		Write-Log "...Updating Profile Name in Local state..."
		$localStateFile = "$Env:LOCALAPPDATA\Microsoft\$EdgeType\User Data\Local State"

		if ($createBackup) {
			$localStateBackUp = "$Env:LOCALAPPDATA\Microsoft\$EdgeType\User Data\Local State Backup"
			Copy-Item $localStateFile -Destination $localStateBackUp
		}

		$state = Get-Content -Raw $localStateFile
		$json = $state | ConvertFrom-Json

		$edgeProfile = $json.profile.info_cache.$profilePath

		Write-Log "......Found profile $profilePath"
		Write-Log "......Old profile name: $($edgeProfile.name)"

		$edgeProfile.name = $profile
		$edgeProfile.shortcut_name = $profile
		$edgeProfile.avatar_icon = "chrome://theme/IDR_PROFILE_AVATAR_$($avatar_array[$($avatar_index)])"
		$avatar_index++

		Write-Log  "......Write profile name to local state: $($edgeProfile.name)"

		# Only uncomment the next line if you know what you're doing!!
		$json | ConvertTo-Json -Compress -Depth 100 | Out-File $localStateFile -Encoding UTF8

		Write-Log "......Write profile name to registry: $($edgeProfile.name)"
		Push-Location
		Set-Location HKCU:\Software\Microsoft\$EdgeType\Profiles\$profilePath
		Set-ItemProperty . ShortcutName "$profile"
		Pop-Location

		#TODO: Customize colors, other preferences automatically for this profile

	}
}

# Update Pinned Taskbar Icons
function Update-TaskbarIcons {
	Write-Log "Updating Taskbar layout - Clear..."
	Set-Layout $taskbar_clear

	# Have to restart Explorer once so that the icon cache is cleared
	Stop-Process -processName: Explorer -Force	

	Write-Log "Updating Taskbar layout - Custom..."
	Set-Layout $taskbar_custom

	Write-Log "Trying to remove Widgets..."
	Remove-Widgets
}

# Helper function to change Taskbar pinned icons layout
function Set-Layout {
	param ($layout)

	# prepare provisioning folder
	[System.IO.FileInfo]$provisioning = "$($env:ProgramData)\provisioning\taskbar_layout.xml"
	if (!$provisioning.Directory.Exists) {
		$provisioning.Directory.Create()
	}

	# save the layout XML to the provisioning folder
	$layout | Out-File $provisioning.FullName -Encoding utf8

	# setup objects for registry updates
	$settings = [PSCustomObject]@{
		Path  = "SOFTWARE\Policies\Microsoft\Windows\Explorer"
		Value = $provisioning.FullName
		Name  = "StartLayoutFile"
		Type  = [Microsoft.Win32.RegistryValueKind]::ExpandString
	},
	[PSCustomObject]@{
		Path  = "SOFTWARE\Policies\Microsoft\Windows\Explorer"
		Value = 1
		Name  = "LockedStartLayout"
	} | group Path

	# update regstry with this layout
	foreach ($setting in $settings) {
		$registry = [Microsoft.Win32.Registry]::LocalMachine.OpenSubKey($setting.Name, $true)
		if ($null -eq $registry) {
			$registry = [Microsoft.Win32.Registry]::LocalMachine.CreateSubKey($setting.Name, $true)
		}
		$setting.Group | % {
			if (!$_.Type) {
				$registry.SetValue($_.name, $_.value)
			}
			else {
				$registry.SetValue($_.name, $_.value, $_.type)
			}
		}
		$registry.Dispose()
	}
}

# Helper function to disable Widgets system in Taskbar
function Remove-Widgets {
	$settings = [PSCustomObject]@{
		Path  = "SOFTWARE\Policies\Microsoft\Dsh"
		Value = 0
		Name  = "AllowNewsAndInterests"
	} | group Path

	foreach ($setting in $settings) {
		$registry = [Microsoft.Win32.Registry]::LocalMachine.OpenSubKey($setting.Name, $true)
		if ($null -eq $registry) {
			$registry = [Microsoft.Win32.Registry]::LocalMachine.CreateSubKey($setting.Name, $true)
		}
		$setting.Group | % {
			if (!$_.Type) {
				$registry.SetValue($_.name, $_.value)
			}
			else {
				$registry.SetValue($_.name, $_.value, $_.type)
			}
		}
		$registry.Dispose()
	}
}

# Run custom application downloader/installer/unzip 
function Install-Custom {
	foreach ($item in $CustomInstallArray) {
		Write-Log "Starting Custom Install Process for $($item.Name)..."
		Write-Log "...Creating Destination Folder $($item.Path)"
		[System.IO.Directory]::CreateDirectory("$($item.Path)") | Out-Null
		$filename = Get-FilenameFromURL -url $($item.Url)
		$extension = [System.IO.Path]::GetExtension($filename)
		$Destpath = Join-Path $($Item.Path) $filename
		Write-Log "...Downloading $($item.Name) to $DestPath..."
		Invoke-WebRequest -Uri $($item.Url) -Outfile $DestPath
	  
		if ($extension -eq '.zip' -and $($item.Action) -eq [CustomInstallAction]::Unzip) {
			Write-Log "...Unzipping $($item.Name) to $($item.Path)..."
	  		Expand-Archive -LiteralPath $DestPath -DestinationPath $($item.Path) -Force
		}
		elseif ($extension -eq '.exe' -and $($item.Action) -eq [CustomInstallAction]::Install) {
			Write-Log "...Starting install of $($item.Name) ..."
	  		Start-Process -Path $DestPath
		}
		else {
			Write-Log "...No applicable action found."
		}

		if($($item.PostInstallScript) -ne $null -and $($item.PostInstallScript) -ne "") {
			Write-Log "...Performing post install script..."
			Set-Location $($item.Path)	# Go to the install folder
			Invoke-Expression $($item.PostInstallScript)
			Set-Location - # Return to previous folder
		}
		Write-Log "...Custom install of $($item.Name) is complete."
	}
}
# Restarts Windows Explorer to make sure changes are applied
function Restart-Explorer {
	# Create a newly installed apps shortcuts folder in current user profile
	mkdir $env:USERPROFILE\Applications > $null

	# Move all installed apps from current user Desktop to above folder
	move $env:USERPROFILE\Desktop\* $env:USERPROFILE\Applications > $null

	# Move all installed apps from Public user Desktop to above folder
	move $env:PUBLIC\Desktop\* $env:USERPROFILE\Applications > $null

	# Now restart the Explorer process
	Stop-Process -processName: Explorer -Force	
}

function Display-Logo {
	Write-Host $Logo
}

# Function to prompt the user with Y/N choice
function Prompt-UserWithTimeout {
	param (
		[string]$Message,
		[int]$Timeout = 10
	)

	$prompt = "$Message (Y/N, default is Y): "
	$default = "Y"

	# Start a timer
	$timer = [System.Diagnostics.Stopwatch]::StartNew()

	# Display prompt
	Write-Host $prompt -NoNewline

	# Read user input with timeout
	while ($timer.Elapsed.TotalSeconds -lt $Timeout -and [Console]::KeyAvailable -eq $false) {
		Start-Sleep -Milliseconds 100
	}

	if ([Console]::KeyAvailable) {
		$inputKey = [Console]::ReadKey($true).KeyChar
	}
 else {
		# No input received, default to Y
		$inputKey = $default
	}

	return $inputKey
}

#endregion Functions

#region Script Block

$script = {
	Run-AsAdmin

	Display-Logo
	$currentDateTime = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
	Write-Log "Starting at $currentDateTime..."
	
	Write-Log $LogPath
	
	# External scripts/software
	Remove-Apps

	# Builtin functions
	Set-ExplorerDefaults
	Set-M365Insider
	Set-PowerSettings
	Install-winget-Updates
	Install-NuGET
	Install-WindowsUpdates
	Install-WingetApplications
	Install-Custom
	Create-EdgeProfiles
	Alter-PathVariable
	Update-TaskbarIcons
	Restart-Explorer

	$result = Prompt-UserWithTimeout -Message "A reboot is recommended for applying all changes. Proceed to reboot?"

	$currentDateTime = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
	if ($result -eq "Y" -or $result -eq "y") { 
		Write-Log "Rebooting system at $currentDateTime..."
		Restart-System
	} 
	else { 
		Write-Host "No reboot selected." 
		Write-Log "Completed at $currentDateTime!"
	}
}
#endregion Script Block

#region Main

Invoke-Command -Scriptblock $script

#endregion Main