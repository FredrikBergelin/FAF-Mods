table.insert(options.ui.items, {
	title = "Command Wheel: Trigger",
	key = 'cw_trigger',
	type = 'toggle',
	default = 'KEY_HOLD',
	custom = {
		states = {
			{text = "Key Hold", key = 'KEY_HOLD' },
			{text = "Key Press", key = 'KEY_PRESS' },
			{text = "Key Up", key = 'KEY_UP' }
		},
	},
})