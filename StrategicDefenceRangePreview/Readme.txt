Strategic Defence Range Preview
===============================
About:
This is the Readme file for the "Strategic Defence Range Preview" modification for Supreme Commander Forged Alliance.
==============================================================
Author:
Katawunga
==============================================================
Description:
This mod erases the need to check the ranges of the enemy SMDs (or TMDs) with a capable builder before firing a strategic or tactical missile.
It does this by showing the range of SMDs and TMDs around the mouse cursor while an SML or TML is selected by holding the shift key.
For a TML, two circles are drawn: A smaller one for the Aeon TMD and a bigger one for the other factions.
This mod also shows a dynamic line from the unitlocation to the current mouselocation, indicating the flight path of the missile for further guidance.
Pressing spacebar while having an SML selected will create a static ring for the range of an SMD at the current mouse location and clicking control will remove all of these static circles.
==============================================================
More details:
For strategic missiles, every unit capable of firing a nuclear warhead is supported.
For tactical missiles, all stationary units (Tactical missile launchers) are supported.
UEF and Seraphim ACUs and SACUs are supported the moment the corresponding missile upgrade is installed.
Mobile missile launchers are not included.
Navy missile launchers are not included.
The list of units can however be modified easily to your desires.
In the "worldview.lua" file, edit the strategicLauncherIDs or tacticalLauncherIDs to your liking.
==============================================================
Inspiration for the code:
Special thanks to the author of the mod "Build Range Preview" and to a lesser extent "Smart Ring Display" and "Notify".
This was my first mod and their code base helped me to get started at cetain stages.
Any feedback as to how I could have implemented something in a better way would be highly appreciated.
==============================================================
Changelog:
Version 0.1
--Added a SMD range (buildrange circle) indicator around the current mouse position while selecting a SML and holding the shift key

Version 0.2
--Added a TMD range (buildrange circle) indicator around the current mouse position while selecting a TML and holding the shift key

Version 0.3
--Added displaying a second TMD range (buildrange circle) indicator for TMLs for the smaller Aeon TMD

Version 0.4
--Fixed a bug which made the mod conflict with a handful of other mods

Version 0.5
--Added support for naval units firing strategic or long range missiles as well as the Yolona Oss

Version 0.6
--Strategic Missile Submarines display both the SMD and TMD range rings simultaneously

Version 0.7
--Swapped the placeholder (buildrange circle) with dedicated strategic and tactical defence range rings respectively

Version 0.8
--Added support for ACUs and SACUs firing tactical missiles (UEF and Seraphim)
--For the Advanced Tactical Missile of the UEF ACU "only" the tactical defence range rings are drawn as it can be shot down by them

Version 1.0 (01.03.2023)
--Released the mod

Version 2.0 (01.03.2023)
--Fixed spelling error in the mod description

Version 3.0 (01.03.2023)
--Fixed mod icon not showing up

Version 4.0 (06.03.2023)
--Added code annotations

Version 5.0 (06.03.2023)
--Added a "line" comprised of many small circles from the unitlocation to the mouselocation indicating the path of the missile for further guidance

Version 6.0 (12.03.2023)
--Improved code annotations

Version 7.0 (19.03.2023)
--Added the functionality to draw arbitrarily many static and persistant circles of the SMD range at the current mouselocation one by one by pressing the spacebar while having an SML selected
--All of these will be removed at once by clicking the control key

Version 8.0 (20.03.2023)
--The line from the unit location to the current mouse position now scales in size depending on the current zoom level of the camera
--This makes the flight path more visible when zoomed far out

Version 9.0 (24.04.2023)
--Minor fixes
--Mobile missile launchers are no longer included as they are rarely used to circumvent TMD

Version 10.0 (20.11.2023)
--The "SetPosition" Function was changed by FAF which resulted in a bug where the rings were not rendered correctly
--Fixed this bug
==============================================================
==============================================================
==============================================================