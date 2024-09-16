# Yabai.spoon

[![Video]](https://private-user-images.githubusercontent.com/5642902/367634752-43f82645-1428-4947-be4f-ee6176fae3dd.mov?jwt=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJnaXRodWIuY29tIiwiYXVkIjoicmF3LmdpdGh1YnVzZXJjb250ZW50LmNvbSIsImtleSI6ImtleTUiLCJleHAiOjE3MjY0NDk2MDEsIm5iZiI6MTcyNjQ0OTMwMSwicGF0aCI6Ii81NjQyOTAyLzM2NzYzNDc1Mi00M2Y4MjY0NS0xNDI4LTQ5NDctYmU0Zi1lZTYxNzZmYWUzZGQubW92P1gtQW16LUFsZ29yaXRobT1BV1M0LUhNQUMtU0hBMjU2JlgtQW16LUNyZWRlbnRpYWw9QUtJQVZDT0RZTFNBNTNQUUs0WkElMkYyMDI0MDkxNiUyRnVzLWVhc3QtMSUyRnMzJTJGYXdzNF9yZXF1ZXN0JlgtQW16LURhdGU9MjAyNDA5MTZUMDExNTAxWiZYLUFtei1FeHBpcmVzPTMwMCZYLUFtei1TaWduYXR1cmU9ODMwNTA2NTg4NjEzYjcwNDFkZmU4ODNlYzIyOTc2MjI1NTI4ZDIwNTNhZGQ0MTM1MjE2ODFkMzY5NjQ5NWM4YSZYLUFtei1TaWduZWRIZWFkZXJzPWhvc3QmYWN0b3JfaWQ9MCZrZXlfaWQ9MCZyZXBvX2lkPTAifQ.Cq5BCAy4-zDYkNjASSoVEH7D2BguMkE_Sca0HL5ohj8)

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
