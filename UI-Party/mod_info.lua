name = "UI Party"
version = 15
copyright = "nah"
description = "Various UI Enhancements. With contributions from many."
author = "Anihilnine, with contributions (technical help / ideas / I stole their code) from Zock, Domino, Myxir, yorick, Sir Prize, Crotalus, Coding Squirrel, Morax, Speed2, Hotbuild, camelCase, HUSAR_PL, MaCielPL, tatsu, sheeo, icedreamer, JoonasTo, Heaven, Fast-Thick-Pants"
url = ""
uid = "022E3DB4-9C00-5ED7-9876-4866D316E015"
exclusive = false
ui_only = true
conflicts = {  }
requires = {"zcbf6277-24e3-437a-b968-Common-v1"}
before = {"zcbf6277-24e3-437a-b968-Common-v1"}
after = { }

-- ### todo

--  options for beep idle fac
--	econtrol tooltip
--	use common (with check that is running and give to myx)
--	remove reclaim from income in eco window (how to do team overspil)
--	show reclaim graph
--	only run test when in dev mode
--	a million silo problems
--	arty power usage problems
--	get rounding fix integrated



-- ### history

-- v15
--  added bindable key to quickswitch observer

-- v14
--  option for starting with Player Colours on (allies = green, enemy = red, you = blue). Inspired by Heaven
--  option for hiding just the resource summary of EControl. Inspired by edmundopt 
--	doubleclicking a non-assister will select all similarly locked non-assisters (used to select all units of that unit type regardless of lock or assistance). Inspired by JoonasTo
--  added bindable key for select onscreen directfire land units. Inspired by Fast-Thick-Pants
--  added bindable key for select onscreen support land units (not direct fire or engineer or ACU or SACU). Inspired by Fast-Thick-Pants
--  added bindable key for split land units by role (directfire/support)

-- v13
--	compatibility with FAF 3680
--  added icedreamer to list of contributors

-- v12
--	notifications - beep & red avatars marker - on idle fac
--	adornments - performance enhancements
--	Econtrol - added power-spent-on-power

-- v11
--	released v10 to public (which was only released to individuals since vault down)

-- v10
--	new: Econtrol ui
--	keys - added Select similar onscreen units
--	keys - added Undo last queue order - works for engies and factories. 
--	beep/message - added for finished structure/acu upgrades.
--	adornments - added upgrading structures
--	adornments - added upgrading acu - this feature requires notify mod, doesnt work in replay
--	adornments - added submerged destroyers + surfaced subs
--	adornments - added loaded tac/nuke/defense missile 
--	adornments - greater emphasis on idle master facs
--	adornments - fixed: double adornments when upgrading fac
--	alternative startup sequence - now for non split screen - thanks to tatsu!
--	alternative startup sequence - fixed: have to reselect acu to get build menu items - thanks to tatsu!
--	performance improvements
--	new settings


-- v9
--	Compatibility with FAF 3642

-- v8
--	Clear queue except for current production - now works for multiple units at once. Also clears the first item if it hasnt been started yet (because another unit is still walking off factory)
--	Adornments - better icons for factories

-- v7
--	manual unit lock
--	adornments
--	double click assister selects similar assisters
--	added key - Reselect Split Units
--	added key - Reselect Ordered Split Units

-- v6
--	bug fix : commandmode doesnt cancel

-- v5
--	added key - clear queue except for current - works for (factory work queue) and (engineer work queue)
--	added option - Factories repeat always

-- v4 
--	unit split
--	settings ui
--	fix ui layout bugs during replay
--	all units start ground fire

-- v3 and earlier
--	units ground fire on attack
--	bug fixes
--	zoom pop override and speed
--	rearrange bottom panes
--	hide menus on start
--	start split screen
--	move and rearrange windows
--	switch to disable mod
