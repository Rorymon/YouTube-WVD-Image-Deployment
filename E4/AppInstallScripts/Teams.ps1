$BuildDir = 'c:\CustomizerArtifacts'
if (-not(Test-Path $BuildDir)) {
    New-Item  -ItemType Directory $BuildDir
}
$allVersions = Get-MicrosoftTeams
$mostRecent = $allVersions | Sort-Object -Descending -Property 'Version' | Select-Object -First 1 | Select-Object -ExpandProperty 'Version'
$allOnVersion = $allVersions | Where-Object { $_.version -eq $mostRecent }
$myVersion = $allOnVersion | Where-Object { $_.Architecture -eq 'x64'}
$fileName = split-path $myVersion.uri -Leaf
$outFile = join-path 'c:\CustomizerArtifacts' $fileName
if (-not(Test-Path $outFile)) {
    Invoke-WebRequest $myVersion.uri -OutFile $outFile
}
$teamsRegKey = 'HKLM:\SOFTWARE\Microsoft\Teams'
New-item $teamsRegKey
New-ItemProperty -Path $teamsRegKey -Name 'IsWVDEnvironment' -Value 1 -PropertyType DWORD
Start-Process -FilePath msiexec.exe -Argument "/i $outFile /qn /norestart ALLUSER=1 ALLUSERS=1" -Wait
Remove-Item $outFile
$stop