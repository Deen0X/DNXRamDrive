$param1=$args[0]
$param2=$args[1]
$param3=$args[2]
$myShortcut="C:\Users\Public\Desktop\" + $param1 + ".lnk"
$MyDir = [System.IO.Path]::GetDirectoryName($myInvocation.MyCommand.Definition)
$WshShell = New-Object -comObject WScript.Shell
$mySC=$WshShell.CreateShortcut($myShortcut)
$Shortcut = $mySC
#$Shortcut.TargetPath="C:\Windows\System32\shutdown.exe"
$Shortcut.TargetPath=$param2
$Shortcut.Arguments="/AUTO"
$Shortcut.IconLocation=$MyDir + "\DNX_MicroSD.ico"
$Shortcut.Save()

$bytes = [System.IO.File]::ReadAllBytes($myShortcut)
$bytes[0x15] = $bytes[0x15] -bor 0x20 #set byte 21 (0x15) bit 6 (0x20) ON
[System.IO.File]::WriteAllBytes($myShortcut, $bytes)