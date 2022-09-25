## TurtleRP

An RP addon custom-made for Vanilla WoW.

For more information, visit [https://tempranova.github.io/turtlerp/](https://tempranova.github.io/turtlerp/).

### To Do

Tests

- // Need to test all iffy characters -- if any bad ones cause an error, it'll error EVERYONE (tested `~!@#$%^&*()-_=+[]\{}|;':",./<>?`)
- More comprehensive tests are worthwhile on bad characters

Bugs

- Test when drunk (SLURRED_SPEECH)

Next Up

- Changing icon on website to Turtle icon, adding link to the Discord
- Adding icon to the frame 
- "RP Mode" like IRP, turning off all frames except chat
- Adding a text input for quickly searching through icons
- Allowing custom class text and custom class color
 - This requires some rethinking of how tooltip is sent, as we're nearing 255 char limit (see Class Constants for char limits). Do we split the tooltip into parts, like description? Or enforce other limits?

Feature List

- More to come after beta testing and first release, based on community response

Recently Done

- // Testing channel being joined properly
- // Fixing sometime disappearance of tooltip
- // description autopops when clicked by another
- // adding pronouns and adding that beside the IC / OOC
- // Passing through HTML for the Description
