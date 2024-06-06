How I install Supcom/FAF + all my mods (and solve problems with my Macbook Pro 16 (2019, base version) running bootcamp)

1. Install Supeme Commander Forged Alliance from Steam
2. Install FAF
3. Start a custom game to test and let FAF download all the necessary files
4. Move/Delete the two music files from SteamLib\steamapps\common\Supreme Commander Forged Alliance\sounds Music.xsb, Music.xwb. Otherwise my game crashes randomly after about 45 min.
5. Run the FAF_process.ahk AutoHotkey script (Not sure if it makes any difference)
6. Run the FAF_WinCtrl.ahk AutoHotkey script. It turns your left windows key (command key on mac) to ctrl, so you dont accidentally tab out and also easier to reach.
7. Download mods, then copy the game.prefs file - make sure the username is correct and other things that you might want to change to your own.
8. On my mac, I can't exit SupCom without it crashing. Use Task manager to terminate process after every game (yeah it's annoying)
9. After making any changes to ingame settings, restart the game so that they persist in your game.prefs file before terminating.
10. Double check the game.prefs file if you want to be sure, before terminating.
11. Take backups of your game.prefs file from time to time. Initializing a git repo at the file location is an easy way.

