name = "Souls PostFX Changes"
version = 2
copyright = "2021 SoulTechnology"
author = "SoulTechnology"
description = "Noticed there were some effects that rely strongly on, or completely require at least SOME bloom to be visible, but unlike a lot of other modern games, Supcom only has a bloom on and off (instead of a slider or multi-options).\n\n So in addition to fixing that, I went through and ‘modernized’ some other camera and postFX related visuals:\n- Bloom is force enabled, but at a much lower strength. Most nukes just about dont blind you completely, but some subtle explosion and shield related effects are now visible that before weren't\n- Camera shake is severely reduced, you can notice it exists, but it should not consistently mess with orders and placement.\n- Shadow quality has been improved.\n- FOV and pitch changes to the camera at different zoom levels (with a lower min-zoom letting you get closer). This also effects render distances on certain effects (did you know antinukes have an impact FX for example?). This also gives a more modern feel to how the camera behaves.\n- Camera should no longer lock pitch in some situations when using spacebar to look around.\n\n Version 2\n- NOW WITH A SETTINGS FILE!\n- New settings for turning off each component of the mod individually\n- Presets for the camera function, so you have vanilla, modern, top-down, and orthographic\n- Yo, want a little bit more bloom or shake then the mod, but less then vanilla?\n- How about just MORE bloom and camera shake then vanilla?!\n- Can also adjust shadow quality if you want even MORE pixels, or just blobs. \n\n I also recommend checking out Souls Boom and Kablamo (a sim mod) for more visually enjoyable nukes.\n Also recommend turning down your pan speed and using arrow keys more "
uid = "a71bae8e-8c12-11ec-a8a3-0242ac1200V2"
exclusive = false
ui_only = true
selectable = true
enabled = true
exclusive = false
icon = "/mods/Souls PostFX Changes/icon.png"
special_thanks = "GPG, FAF Team & community, https://supcom.fandom.com/wiki/Console"
conflicts = {
"06E0D4F2-2231-11E3-A9FB-92EE6088709B", --No Camera Shake
"a71bae8e-8c12-11ec-a8a3-0242ac120002" -- Previous Version
} 