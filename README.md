# Yabai.spoon

A HammerSpoon Yabai integration which provides:

1. UI Elements for adding, labeling, and navigating spaces.
2. MenuBar icon displaying current space with drop down to select a space
3. Clickable on-screen stack indicator
4. MenuBar stack indicator and drop down for stack window selection
5. Automatic empty space deletion

## Usage

Follow directions for installing a Spoon on HammerSpoon's documentation.

Load it with defaults in your `init.lua`.

```lua
local yabai = hs.loadSpoon('Yabai')
yabai:bindHotkeys(nil)
yabai:configure({ showSpaceMenuBarIcon = false })
yabai:start()
```

## Configuration

### Config
```lua
local defaultConfig = {
	showSpaceMenuBarIcon = true,
	cleanEmptySpaces = true,
	showOnScreenStackIndicator = true,
	showStackIndicatorMenuBarIcon = true
}
```
`spaceMenuBarIcon` - Show the MenuBar icon with a drop down to select a space
`cleanEmptySpaces` - Automatically delete empty spaces
`showOnScreenStackIndicator` - Show the on-screen stack indicator
`showMenuBarStackIndicator` - Show the MenuBar stack indicator

### Keymaps

```lua
local defaultHotKeysMapping = {
	createSpace = { { "alt", "shift" }, "n" },
	selectSpace = { { "alt" }, "w" },
	labelSpace = { { "alt" }, "r" }
}
```

Both configuration and keymaps can be overwritten on a per-key basis:
```lua
yabai:bindHotkeys({ createSpace = { { "alt", "shift" }, "x" } })
yabai:configure({ showSpaceMenuBarIcon = false })
```
