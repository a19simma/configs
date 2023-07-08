Install boxstarter and change execution policy:
`Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://boxstarter.org/bootstrapper.ps1')); Get-Boxstarter -Force`

Run the script:
`Install-BoxstarterPackage -PackageName https://raw.githubusercontent.com/a19simma/configs/master/windows/boxstarter.ps1 -DisableReboots`
