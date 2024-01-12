##
## Section 1: Information Gathering
##

# Get appdir.
$user_appdir = [Environment]::GetFolderPath("ApplicationData")

# Get desktop directory.
$common_documents = [Environment]::GetFolderPath("CommonDocuments")

# Get current user.
$current_user = [Environment]::UserName

##
## Section 2: Set variables we'll use later.
##

# Set Stardew Valley saves directory.
$stardew_saves_dir = "$user_appdir\StardewValley\Saves"

# Set Stardew Valley backups directory.
$stardew_backup_dir = "$common_documents\StardewValleySaveBackups"

# Set Stardew Valley user specific backups directory.
$stardew_user_backup_dir = "$stardew_backup_dir\$current_user"

##
## Section 3: Sanity Checks
##

# Tell the user what's up.
Write-Host ""
Write-Host "Checking for Stardew Valley saves..."
Write-Host ""

if (Test-Path -Path "$stardew_saves_dir")
{
	Write-Host "Found saved games: $stardew_saves_dir"
	Write-Host ""
}
else
{
	Write-Host "No saved games present."
	Write-Host ""
	exit 1
}

# Check for top level backups folder.
if (Test-Path -Path "$stardew_backup_dir")
{
	Write-Host "Found backups directory: $stardew_backup_dir"
	Write-Host ""

	# Check for backups folder for this user, specifically.
	if (Test-Path -Path "$stardew_user_backup_dir")
	{
		Write-Host "Found backups directory for current user: $stardew_user_backup_dir"
		Write-Host ""
	}
	else
	{
		# Create backups folder to copy saved games to.
		Write-Host "No backups directory for this user present, creating a new one."
		Write-Host ""
		New-Item -Path "stardew_backup_dir" -Name "$current_user" -ItemType Directory | Out-Null
	}
}
else
{
	# Create backups folder to copy saved games to.
	Write-Host "No backups directory present, creating a new one."
	Write-Host ""
	New-Item -Path "$common_documents" -Name "StardewValleySaveBackups" -ItemType Directory | Out-Null
	New-Item -Path "$stardew_backup_dir" -Name "$current_user" -ItemType Directory | Out-Null
}

##
## Section 4: Run Backups
##

# Get last modified time of saves directory and convert to sane string ("yyyyMMddHHMMss").
$saves_modified_time = (Get-Item "$stardew_saves_dir").LastWriteTime
$saves_modified_time_string = $saves_modified_time.ToString("yyyyMMddHHMMss")

# Look for a directory with the above string in our backup directory.
$backup_names = (Get-ChildItem "$stardew_user_backup_dir").Name

if ($backup_names -contains $saves_modified_time_string)
{
	Write-Host "Backup already present."
	Write-Host ""
}
else
{
	Write-Host "Backup missing, copying files..."
	Write-Host ""
	New-Item -Path "$stardew_user_backup_dir" -Name "$saves_modified_time_string" -ItemType Directory | Out-Null
	Copy-Item -Path "$stardew_saves_dir" -Destination "$stardew_user_backup_dir\$saves_modified_time_string\" -Recurse | Out-Null
}

Write-Host "All done!"
Write-Host ""

Read-Host -Prompt "Press Enter to exit"
