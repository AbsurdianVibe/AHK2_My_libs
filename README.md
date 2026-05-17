# Mouse Click Handler

This repository contains a script for advanced mouse click handling. 
Currently, it has only one script. 
I use this script in multiple parallel repositories.

## Main Function: Multiklik

`Multiklik` handles advanced click logic like hold, short click, and double click.

## Legacy

 The code, variables, and comments are in Polish. This is legacy code from before publishing to GitHub.
 
## Requirements

* **You must install AutoHotkey v2.0.**
* **Do not copy only the `Multiklik` function.** 
* **It needs `SprawdzRuchMyszy` and `ObliczDystans` helper functions to work.**

## Instant Mode

* The script supports an "Instant" scenario.
* In this mode, the hold action starts right away.
* If you release the button fast and do not move the mouse, it checks for a double click.

### Parameters:

* `klawisz` (String): Key name to listen to (for example: "LButton", "XButton1").
* `akcjaShort` (Func): Function called on a short click.
* `akcjaHold` (Func): Function called on a hold.
* `akcjaDoubleShort` (Func) [Optional]: Function called on a normal double click.
* `akcjaDoubleHold` (Func) [Optional]: Function called on a double click and hold.
* `czasPrzytrzymania` (Float) [Optional]: Time in seconds to register a hold[cite: 8]. Default is 0.2.
* `trybInstant` (Integer) [Optional]: If greater than 0, `akcjaHold` starts immediately. This value is the pixel limit. Mouse movement inside this limit is ignored for `akcjaShort`.