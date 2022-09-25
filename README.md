## TurtleRP

An RP addon custom-made for Vanilla WoW.

For more information, visit [https://tempranova.github.io/turtlerp/](https://tempranova.github.io/turtlerp/).

To archive from source code, use `git archive --output=TurtleRP-0.0.3.zip --prefix=TurtleRP/ HEAD`.

### To Do

Tests

- // Need to test all iffy characters -- if any bad ones cause an error, it'll error EVERYONE (tested `~!@#$%^&*()-_=+[]\{}|;':",./<>?`)
- More comprehensive tests are worthwhile on bad characters
- Testing tooltips across different game situations (in raids, parties, bgs, etc)

Bugs

- Framerate issues when opening tooltips? reported 2s lag
- Test when drunk (SLURRED_SPEECH)

Next Up

- "RP Mode" like IRP, turning off all frames except chat
- Allowing custom class text and custom class color
 - This requires some rethinking of how tooltip is sent, as we're nearing 255 char limit (see Class Constants for char limits). Do we split the tooltip into parts, like description? Or enforce other limits?

Feature List

- More to come after beta testing and first release, based on community response

Recently Done

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
