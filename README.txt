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


Mods todo:

- Color Coded Strategic Icons
    - Finish structures
    - Set common middle parts, for example splash damage is horizontal line, missiles are vertical line
    - Add more individual icons wherever necessary. Lightning tank? 
- ECOntrol
    - Update icons
        - "nuke_category" is used for all missiles, split or merge?
    - Subcategories? Expandable?
    - Show all from start, so they can be configured during early game as well
    - Add more modes: Pause, AutoPause, AutoActivate (for example all new ASF should activate stealth), Prioritize (AutoPause others), ...
    - Exenditure should scale with the highest one filling the bar, others sized based on how they differ from that one.
- 

New mod ideas:

- ResourceControl
    - Hotkeys to pause and unpause everything that drains energy. Construction, abilities, and weapon fire stance when requiring energy.

    - Pausing / Auto-pausing artillery should put them into no fire stance, its the only way to halt their energy use. Both CapsLock and UI-party ECOntrol

    - Shields deactivates on CapsLock AND on shift-CapsLock and must be manually activated.
