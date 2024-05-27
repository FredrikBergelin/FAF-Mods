# CommandWheel

Util Wheel
----------------------------------
- **[U] Naval** - select all naval units on map
- **[U] AA** - select all land anti air units on map
- **[F] Land** - select all land factories on map
- **[F] Air** - select all air factories on map
- **[A] Snipe** - select all air to land units on map
- **[A] Trans** - select all transports on map
- **[F] Fighter** - select all air fighters on map
- **[I] Scouts** - select all idle air scouts on map
- **[I] Engineer** - select all idle air engineers on screen
- **[G] Mass** - gives 50% mass to ally
- **[G] Energy** - gives 50% energy to ally

**Note**: Mass and Energy command use following logic:
- Check if any ally send energy or mass request in chat in past 15 seconds
- Check whoever got lower mass/energy rate in team

Configuration
----------------------------------

Navigate to mod folder and open `Config.lua` in any text editor and modify `Wheels` variable.
* You can freely add, delete or modify all columns and items
* You can add new wheel similar to existing

**Wheel**
- Mods - List of mods required for the wheel
- Mods.Name - Name of required mode
- Mods.Location - Location of required mode
- Mods.Uid - Uid of required mode
- Position = 'MOUSE' - Create Wheel at mouse position
- Position = 'CENTER' - Create Wheel at middle of the screen
- Trigger = 'KEY_HOLD' - Open Wheel by key hold and close by key up
- Trigger = 'KEY_PRESS' - Open Wheel by key press without closing
- Trigger = 'KEY_UP' - Open Wheel by key hold and select sector by key up
- Ui.Radius - Wheel radius in px if value => 1 or relative to screen size if value < 1

**Middle**
- Ui.Middle.Type = 'EMPTY' - Empty middle circle
- Ui.Middle.Type = 'SIMPLE' - Middle circle with action
- Ui.Middle.Radius - Middle circle radius in px if value => 1 or relative to Wheel size if value < 1
- Ui.Middle.Alpha - transparency coefficient when not hovered
- Ui.Middle.Hover.Alpha - transparency coefficient when hovered
- Ui.Middle.ActionType - Type of action on press (see **Actions**)
- Ui.Middle.Action - Action command (see **Actions**)
- Ui.Middle.Text - Array of text entities
- Ui.Middle.Text.Value - Text value
- Ui.Middle.Text.Size - Text size in px if value => 1 or relative to Wheel size if value < 1
- Ui.Middle.Text.Color - Text color in hex
- Ui.Middle.Text.Font - Text font 
- Ui.Middle.Texture - Texture name, currently only 'DEFAULT' supported

**Sector**
- Ui.Sector.Type = 'SIMPLE' - Circle sector with action
- Ui.Sector.Alpha - transparency coefficient when not hovered
- Ui.Sector.Hover.Alpha - transparency coefficient when hovered
- Ui.Sector.ActionType - Type of action on press (see **Actions**)
- Ui.Sector.Text.Size - Text size in px if value => 1 or relative to Wheel size if value < 1
- Ui.Sector.Text.Color - Text color in hex
- Ui.Sector.Text.Font - Text font
- Ui.Sector.Texture - Texture name, currently only 'DEFAULT' supported
- 
**Items**
- Supported items counts: 4, 8, 12, 18
- Items.ActionType - Type of action on press (see **Actions**)
- Items.Action - Action command (see **Actions**)
- Items.Text - Array of text entities
- Items.Text.Value - Text value
- Items.Text.Size - Text size in px if value => 1 or relative to Wheel size if value < 1
- Items.Text.Color - Text color in hex
- Items.Text.Font - Text font

Actions
----------------------------------
**PING**
- MarkerText - Text of the marker
- MarkerNickname - Add nickname to marker text
- MarkerTimestamp - Add current ingame timestamp to marker text
- Action - One of 'marker', 'alert', 'move', 'attack'

**KEY_ACTION**
- Action - Any keyaction supported by FAF, see https://github.com/FAForever/fa/blob/deploy/fafdevelop/lua/keymap/keyactions.lua

**TARGET_PRIORITY**
- Action - Target priority name, see 'Advanced target priority mod'

**CHAT**
- MessageTo - Message destination: 'allies' or 'all'
- Action - Message text

**GENERIC**
- Action - Reference to any zero argument function

**!!!** After any changes to `Config.lua` run game locally and make sure that it works correctly **!!!**