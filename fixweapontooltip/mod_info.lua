name = "Fix Weapon Tooltips"
uid = "88bcfca0-0a21-4eec-9c5a-6723e37c5585"
version = 8
description = "Fixes several issues that causes certain mod units to be unselectable. Splits weapons with the same name properly. The base game treats all weapons with the same name as the same weapon, even though a unit may have multiple weapons with the same name but different stats. Also adds a total DPS summary, split into direct fire, range groups, anti air, anti navy DPS. These summaries are particularly useful for mods where T4 units have dozens of weapons. Also see https://github.com/FAForever/fa/issues/3236 for more details. Updated by Nomander with permission from Divran."
author = "Divran, Nomander"
icon = "/mods/fixweapontooltip/mod_icon.png"
exclusive = false
ui_only = true
conflicts = {
    "a0d05499-43ec-4a28-a51f-81bcf78af5d9", --"Fix weapon tooltip" version 4
    "78be128c-2f5a-41d1-8212-ea0ae35666ad", --"Fix Weapon Tooltips" version 5
    "87e27c79-abad-430a-a0f7-f60bbf4a85d1", --"Fix Weapon Tooltips" version 6
    "c05b6ab7-113d-47b9-b7b5-04581d794173", --"Fix Weapon Tooltips" version 7
}
