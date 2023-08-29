***************************************
| ADMIRALZEECH'S ECONOMY TOOLS MOD - FA
***************************************

---------------- 
|Overview

Semicolon (;) key displays EcoInfo panel. 
[Shift + ;] activates energy saver Autopause on selected units. 
[Ctrl+Shift+;] Toggles AutoMassfabs.


-----------------
| EcoInfo Display

Pressing semicolon [;], will open a panel with the following info:

BASED ON YOUR CURRENTLY SELECTED UNITS:

* M Use: ( 50% ) 10000
- How much mass the units are currently using.
In brackets is percentage of total INCOME.


* M Req: ( 50% ) 10000
- How much mass the unit is requesting.
In brackets is the percentage of total SPENDING.
 

* E Use: ( 50% ) 10000
- How much energy the units are currently using.
In brackets is percentage of total INCOME.


* E Req: ( 50% ) 10000
- How much energy the unit is requesting.
In brackets is the percentage of total SPENDING.


INFORMATION ON ALL YOUR MASSFABS:
* Fabs ( 10 / 100 ) [AUTO]
- In brackets is how many massfabs are active out of the total
number. Both types are counted as 1 here.
[AUTO] is displayed when the Auto Massfab Manager is active. See below.

* E Use: ( 50% ) 10000
- How much energy your activated massfabs are using.
In brackets is the percentage of total energy income.



--------------
| AUTO PAUSER

Sometimes in the game you want to build something that eats up a lot
of resources.  You're happy to let things go into negative mass, but you
dont want to bottom out your energy since everything will shut down.

The Auto Pauser will pause construction when your energy is low, and
restart it when your energy is full.  So you can get the thing built
in bursts.   Of course your energy will yo-yo during this time, so
it's only recommended for special projects.

To use it:
- Select your units
Eg. A nuke silo and all SCUs assisting it.

- FIRST START THE CONSTRUCTION
The Auto Pauser will only work when there is some Progress occuring.

- Press [Shift + ;]
A label "AUTOPAUSE" will appear beneath the units.

- When the item is complete, the auto pauser will deactivate
  automatically.
The "AUTOPAUSE" label will dissappear.



----------------------
| AUTO MASSFAB MANAGER

Automatically turns mass fabricators on and off based on how much
energy you have.

The algorithm I use is pretty basic and slow, but does the job.  You
may want to use other peoples' mods for this, so this feature DEFAULTS
TO OFF.

Activate it by pressing [Ctrl + Shift + ;] You need to do this at the
start of every game.

The manager scans for new massfabs when you press [;] to open the
EcoInfo panel.  So when you're building new massfabs, YOU NEED TO
TOGGLE THE ECOINFO PANEL TO REGISTER THE NEW MASSFABS.

You should develop an intuitive reaction - build a bunch of massfabs,
your energy plummets, you go "WTF!?!?" and open the EcoInfo panel to
see what's going on, and magically everything's alright again :P



----------------------- 
| Key and Function List 

[;] (Semicolon key)
- Toggles the EcoInfo panel
- When the panel is OPENING, it will scan for new massfabs to register
into the massfab manager.

[Shift + ;] 
- Activates Energy Saver Autopause on selected units.
- The only way to turn off Autopause is to either let the unit
complete its task, or give it the STOP command.

[Ctrl+Shift+;] 
- Toggles AutoMassfab Manager.
- This defaults to off, so you need to activate it when you want to
use it.



----------------------- 
| Tips and notes

You might be curious about exactly how the algorithms I use work.

*** AutoMassfab Manager ***
It's tuned to use up any energy that would be wasted.  So when your
energy storage is full, it will activate massfabs until your net
energy income is just above zero.

If your energy storage goes below 90%, it will turn off all massfabs
and let your energy refill.

Since T2 fabs are more efficient in FA, whenever it can replace a T3
fab with T2 fabs that use the same amount of energy, it will shut down
the T3 Fab in favour of the T2 ones.  Your mass income should
increase.

Although you shouldnt build T3 Fabs in the first place in FA :P


*** Auto Pauser ***
When your energy storage is below 70%, it will pause construction (as
if you pressed the Z key) on the affected units.  When your energy is
above 90%, it will unpause the construction.

The AutoPauser will remove itself from the unit when the unit's has
completed its current item.


------------------ 
| The End

This mod is mainly for my own comfort and use, so it's provided "As
is".  However, if you have a feature request and have a good reason
for it, tell me and I'll think about it.

Of course, Bug Reports are always welcome.


Possible future work:
- Make an additional Auto Pauser function that tracks both Mass and
Energy.
- Save the AutoMassFab Manager state in game.prefs so you dont need to
turn it on every single game.


This mod was written using EmacsW32, together with lua-mode.el

Bye-Be!  
-AdmiralZeech
