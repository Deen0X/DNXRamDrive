DNX RamDrive (DNXRD) By:DNX.Projects

Disclaimer

The author of this shareware accepts no responsibility for damages resulting from the use of this product and makes no warranty or representation, either express or implied, including but not limited to, any implied warranty of merchantability or fitness for a particular purpose.

This software is provided "AS IS", and you, its user, assume all risks when using it.

This script is supported by the project ImDisk for creating the virtual drive
https://github.com/LTRData/ImDisk
https://sourceforge.net/p/imdisk-toolkit/discussion/general/

Description of this script

The basic idea is to optimice slow windows systems (with low speed discs) and most of all, MicroSD running Windows on it (Win2Go), using a ramdrive for allow the system to write temporal and cache files.
The script will confiure the TEMP, TMP variables based on the need of creating or not the Ramdrive
The script will check the speed of the system drive (C:) and based on this will create the virtual drive.
The artibary value for considering a drive is Fast or Slow, is: under 100MB/s is slow.

Based on the RAM of the device, will create a ramdrive following this table:
Over 16GB RAM will create a 4GB RamDrive
16GB RAM will create a 3GB RamDrive
 8GB RAM will create a 2GB RamDrive
 4GB RAM will create a 1GB RamDrive
 2GB RAM or less, will not create a RamDrive on the system.
 
The script will create an entry on the desktop for launching itself.
The script will create an entry on the registry for launch itself every time windows starts.
For disable this, you can delete this entry:
HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Run
 - .DNXRamDrive
Or simply you can disable the entry on the Windows Task Manager/Startup programs.

When the script is launched, will set the TEMP and TMP variables to "C:\Temp" (the folder will be created if not exist)
If the drive is created, then will set to "C:\TempRD" using a directory join to "Z:\Temp"
if the drive is created, then will set the cache folder of Chrome to "Z:\ChromeCache" and Edge to "Z:\EdgeCache" using directory join to their local folders on C:

If the script consider that is not necessary to create a RamDrive, then will try to unload any existent drive.

There are some parameters:

PARAM1: /FASTMEDIA /LOWMEDIA /AUTO
	FASTMEDIA force the script to consider a fast media, without running a Speed Test. This may be useful for unload drivers.
	SLOWMEDIA force the script to consider a slow media, widhout running a Speed Test. This may be useful for force the creation of a RamDrive
	/AUTO     Allow to the script to check the drive speed running a Speed Test, and based on their results define is this is a FAST or SLOW media
	
PARAM2: [number]
	[number] correspond to a fixed ammount of GB to be used for creating a RamDrive. This bypass the check of physical RAM on the device and determine the size of the RAMDRIVE to be created.
	
PARAM3: /NOINSTALL
	NOINSTALL force the script to not install the driver. This maybe useful if you are doing tests with the script, or if your system always will use the RamDrive, so is not necessary to install every time the script is runnng.


Hope you found useful this script.

For more info, sugestions, etc. visit our Telegram channel.
https://t.me/PCMasterRacePortable/673587

Deen0X.
