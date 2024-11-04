# fisticuffs_v1.0.0
Follow structure from "godot platform fighter series".
 
## Dimensions
For now, keep 800 width and 600 height, for a 4:3 ratio like SF3

## Differences with respect to tutorial
- Walk takes place of Dash
- frame function is _frame, to not be redundant with frame var

## Progression
- Part 4, 21:00
- Check why we fall through floor after jumping, check raycasts which may be different in godot 4
- Reason was Raycasts need to be "Hit from inside" = On, and I forgot to change John's collision layer mask
- Small changes to do in "Revamping your Plat... Godot 4.0", which were the reason for the bugs
- replace clamp and lerp by clampf and lerpf
 
