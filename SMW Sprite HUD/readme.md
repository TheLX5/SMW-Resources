## SMW Sprite HUD
Recreation of SMW's HUD in UberASM (+ minor patches). Includes status bar and the level end display. Mode 7 bosses were not tested.

Version 1.0

## Requirements
* [DSS 1.01 or newer (2.0 recommended)](https://github.com/TheLX5/DynamicSpritesetSystem/releases)
* [SA-1 Pack 1.40 or newer](https://www.smwcentral.net/?p=section&a=details&id=25938)
* [UberASM Tool 2.0](https://github.com/Fernap/UberASMTool/releases)

## Usage
* Place the files in the corresponding folders
* Use the following lines in your UberASM Tool list and insert them
```
level:
* 	status_bar.asm
```

## Additional resources
* [Optimize Score Display](https://www.smwcentral.net/?p=section&a=details&id=35746)
* [Remove Status Bar](https://www.smwcentral.net/?p=section&a=details&id=18862)

Do not patch them, they're already embedded into the UberASM script.
