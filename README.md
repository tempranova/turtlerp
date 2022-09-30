## TurtleRP

An RP addon custom-made for Vanilla WoW.

For more information, visit [https://tempranova.github.io/turtlerp/](https://tempranova.github.io/turtlerp/).

To archive from source code, use `git archive --output=TurtleRP-<v>.zip --prefix=TurtleRP/ HEAD`.

### To Do

Tests

- Testing tooltips across different game situations (in raids, parties, bgs, etc)
- Test when drunk (SLURRED_SPEECH)

Bugs

- Tooltips with icons result in inconsistent spacing
- A few blank lines are added on bottom of Shagu tooltips occasionally
- Not recentering description properly on large name?

Next Up

- Prevent pinging when gone AFK
- Doing a quick directory version with Descriptions

After beta

- Adding a directory of characters
- Adding relationships/status tab
- Slight adjustment in PvP text padding/spacing when icon added while PvP enabled
- Showing class colors in /say (harder than it seems! Maybe just use Shagu instead)

Feature List

- More to come after beta testing and first release, based on community response

Recently Done

0.1.3
- Name fields combined into one
- Custom class color
- Custom class
- Custom race
- Improved communication to allow multiple message chaining in the future for all fields
- New field limits for mouseover responses:
  - Full name : 50
  - IC and OOC info: 75 each
  - Pronouns: 10 each
  - Class : 15
  - Race : 20
  - Class color : 6
  - Icon : 4 (internal)
  - IC/OOC : 1
  - Internal: Prefix 3, name 12, key 5, delimiter 10 (?)
  - TOTAL MAX : just under 300 . Lots of room for more'
- New comms system should allow full lengths on At A Glance descriptions
- Changed IC/OOC from "on" vs "off" to 0 vs 1
- Change delimiter to ~ instead of && (fewer characters) -- breaking change, old versions and new versions can't communicate
- Change validator to prevent use of ~ in saved text
- When minimap icon dragged, no longer pops admin panel
- Pipe character (|), when first character of an emote, will remove the character name from the emote text
- Icon Tray
  - Moveable by drag
  - RP button on/off
  - IC button on/off
  - /c chatbox opener
  - Admin button opener
- Chatbox v1
  - click in box/out for focus management
  - Selection of Yell, Emote, Say
  - Emote never uses username
  - Quotation color retained on long form quotes broken by multiple lines
  - Special emote chat now showing on all frames with SAY
  - Text clears after sending
- Setting to change size of name
- Minimap icon size options
- Open to show/hide tray
- Fix icon placement on PFUI spellbook
- Changing /c to dialog icon
- Removed extra space added to front of | emote (space still required
- Setting to hide/show minimap icon
- Icon for TurtleRP switched to mini turtle
- Issue with item comparison fixed PFUI
0.1.2
- // Description box should no longer get cut off
- // Emotes now show "Quotations in White"
- // When a player is ??, tooltip shows -1
- // Improved pinging system
- // More legit resetting of font sizes in tooltip
- // Integrated with Shagu darkmode
- // Guild rank integrated into tooltip
- // Tooltip layout integrated with PFUI
- // Target removed when targetting a player after targetting self
- // Showing version number in ? section
0.1.1
- // New Spellbook UI
- // Implementing a Test channel for future dev changes
- // Not allowing "&&" characters in any saved text
- // Better validation on recieving data
- // Adding discord link to the About section
- // Having a "clear cache" button or something
- // Manually rejoining channel issue
- // Filter icon bug when scrolled fast to end
- // Tooltip ALL lines need resetting (ie, lines 4-5-6)
- // Tooltip "already equipped" issue of not disappearing
- // Some more validation on chat messages
- // 30s ping and announcement system to prevent chat spam
- // Proper chat throttling via ChatThrottleLib
- // Refactor into components and scripts, using XML more effectively
- // "RP Mode" like IRP, turning off all frames except chat
- // 1000+ character descriptions getting cut off in scrollbar
- // Fix with wrong icons being selected when filtering
- // Refactoring tooltip generation to be robust
- // Tooltips are missing health bar underneath
- // Adding a "notes" section
- // Limiting description to 2000 characters
- // Adding a text input for quickly searching through icons
- // Adding icon to the frame
- // Changing icon on website to Turtle icon, adding link to the Discord
- // Testing channel being joined properly
- // Fixing sometime disappearance of tooltip
- // description autopops when clicked by another
- // adding pronouns and adding that beside the IC / OOC
- // Passing through HTML for the Description
