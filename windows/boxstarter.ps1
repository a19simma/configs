Disable-UAC
$Boxstarter.AutoLogin=$false
Set-WindowsExplorerOptions -EnableShowHiddenFilesFoldersDrives -EnableShowProtectedOSFiles -EnableShowFileExtensions

choco install -y mingw
choco install -y git
RefreshEnv
git clone https://github.com/a19simma/configs.git "$env:USERPROFILE\Documents\configs"

. "$env:USERPROFILE\Documents\configs\windows\scripts\unbloat-windows.ps1"
. "$env:USERPROFILE\Documents\configs\winwdows\scripts\configure-windows.ps1"
. "$env:USERPROFILE\Documents\configs\winwdows\scripts\install-apps.ps1"
. "$env:USERPROFILE\Documents\configs\winwdows\scripts\apply-configs.ps1"

Enable-UAC
