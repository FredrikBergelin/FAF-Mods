# StrategicRings

Configuration
----------------------------------

Navigate to mod folder `~\Documents\My Games\Gas Powered Games\Supreme Commander Forged Alliance\mods\StrategicRings\modules` and open `Config.lua` in any text editor.
Modify `Menus` variable in following way:
* Each top level object (`Default`) represents separate menu
* Each menu consists of columns and items in columns. For example `Default` menu has 2 columns and first columns contains 7 items (2 labels and 5 buttons)
  * `Type = "Label"` - simple text
  * `Type = "Button"` - action button
    * `Text` - label of button
    * `Action` - specifies custom action handler. Supported `DELETE_CLOSEST`, `DELETE_LAST`, `DELETE_SCREEN`. Works similar to main key handlers
    * `Radius` - radius of the ring, check FAF unit database
    * `Texture` - color of the ring. Supported `BLUE`, `RED`, `VIOLET`, `YELLOW`.
    * `Static` - specifies whether ring will be placed in exact mouse position or can be moved before placing (possible to add multiple rings by using `Shift`)
* You can freely add, delete or modify all columns and items
* You can also add new menu similar to existing, for example:

`Config.lua`
```
    MySuperUsefullMenu = {
        {
            {Type = "Label", Text = "Galactic Commander"},
            {Type = "Button", Text = "Mavor", Radius = 4000, Texture = "BLUE", Static = true},
            {Type = "Button", Text = "Salvation", Radius = 1800, Texture = "VIOLET", Static = true},
            {Type = "Button", Text = "Yolona Oss", Radius = 4000, Texture = "YELLOW", Static = true},
            {Type = "Button", Text = "Scathis", Radius = 2000, Texture = "RED", Static = false},
        }
    },
```

**!!!** After any changes to `Config.lua` run game locally and make sure that it works correctly **!!!**