## TurtleRP

An RP addon custom-made for Vanilla WoW.

For more information, visit [https://tempranova.github.io/turtlerp/](https://tempranova.github.io/turtlerp/).

To archive from source code, use `git archive --output=TurtleRP-<v>.zip --prefix=TurtleRP/ HEAD`.

### To Do

Tests

- GO TO CITY TO TEST FRAMES, random error popped tooltip

- Testing chat messages for causing global errors to players by mean players. Simulating data responses, etc. How much does this need to be watched?
- Test all iffy characters -- if any bad ones cause an error, it'll error EVERYONE (tested `~!@#$%^&*()-_=+[]\{}|;':",./<>?`)
- Testing tooltips across different game situations (in raids, parties, bgs, etc)
- Test when drunk (SLURRED_SPEECH)
- // Framerate issues when opening tooltips? reported 2s lag

Bugs

- When a player is ??, tooltip shows -1

Next Up

- Minimap icon size options
- Emote changes with emotes and white quotations, coloured names, etc

After beta

- Adding a directory of characters
- Increasing lengths of tooltip notes and AAG notes
- Adding relationships/status tab

- Allowing custom class text and custom class color
 - This requires some rethinking of how tooltip is sent, as we're nearing 255 char limit (see Class Constants for char limits). Do we split the tooltip into parts, like description? Or enforce other limits?
- Slight adjustment in PvP text padding/spacing when icon added while PvP enabled

Feature List

- More to come after beta testing and first release, based on community response

Recently Done

- // More legit resetting of font sizes in tooltip
- // Integrated with Shagu darkmode
- // Guild rank integrated into tooltip
- // Tooltip layout integrated with PFUI
- // Target removed when targetting a player after targetting self
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
