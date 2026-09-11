# RYEENZYXNZ UI V3.1 Fixes

- Fixed fatal `Enum.EasingStyle.Spring` error by using a valid Back easing style.
- Improved config serialization for Color3, EnumItem, UDim2, Vector2, Vector3 and BrickColor.
- Added Mac-style window methods: Show, Hide, Toggle, SelectTab, SetTitle, SetSubtitle, SetLogo, SetBackgroundImage, SetSize, Dialog.
- Added window state/settings helpers and notification toggling.
- Added Label, SubLabel, Header, Divider, Image and ProgressBar components.
- Added Slider `SetValue` / `GetValue`.
- Added Dropdown `UpdateSelection`.
- Added MultiDropdown `UpdateSelection`.
- Added ColorPicker `SetColor` / `GetColor`.
- Added textbox aliases.
- Added config discovery helpers.
- Improved destroy/cleanup behavior and tracked drag connections.
- Fixed slider divide-by-zero edge case.
- Fixed the example to use the user's public GitHub path.
