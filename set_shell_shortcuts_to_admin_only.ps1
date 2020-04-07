function requireAdminRightsForShortcut($path) {
   $bytes = [System.IO.File]::ReadAllBytes($path)
   $bytes[0x15] = $bytes[0x15] -bor 0x20 #set byte 21 (0x15) bit 6 (0x20) ON
   [System.IO.File]::WriteAllBytes($path, $bytes)
}

requireAdminRightsForShortcut "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Git\Git Bash.lnk"
requireAdminRightsForShortcut "$Home\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\System Tools\Command Prompt.lnk"
requireAdminRightsForShortcut "$Home\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Windows PowerShell\Windows PowerShell.lnk"
requireAdminRightsForShortcut "$Home\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Windows PowerShell\Windows PowerShell (x86).lnk"
requireAdminRightsForShortcut "$Home\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Windows PowerShell\Windows PowerShell ISE (x86).lnk"
requireAdminRightsForShortcut "$Home\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Windows PowerShell\Windows PowerShell ISE.lnk"

