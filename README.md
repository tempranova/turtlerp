## TurtleRP

An RP addon custom-made for Vanilla WoW.

For more information, visit [https://tempranova.github.io/turtlerp/](https://tempranova.github.io/turtlerp/).

To archive from source code, use `git archive --output=TurtleRP-<v>.zip --prefix=TurtleRP/ HEAD`.

### To Do

Tests

- Sometimes new name isn't appearing right away (not updated when open?) -- requires a target or mouseover to get updated currently?

Bugs

- Race/class overlap with Current status

- Color pick is sometimes connected to other color picker instances
- Not disabled in BGs
- Custom colors for emotes get overwritten
- Slight adjustment in PvP text padding/spacing when icon added while PvP enabled

Next Up

### Recently Done

1.1.0

- Directory layout and scroller
- Showing online/offline status
- Correcting issues with missing line breaks in non-HTML descriptions (?)
- Ability to query mouseover (two second delay between requests required, possible bug as well)
  - Can't show guild
- /ttrp dir or /ttrp directory opens directory
- New buttons added to the tray (directory, helm, cloak)
- Click on header columns to sort
- Type into bottom search to filter by full name or player name
- Selection between Zone and Character Name listing, both sortable
- Sending zone along with ping
- Find other RPers on a map when entering a zone (must be in the zone, updated every 30 sec)
- Permissions for sharing exact location with other players
- Improving chat error catching
  - Confirmation required when sending any emote with odd "s (long or short form)
- Version tracker (chat message and note in admin panel)
- Resetting defaults on tooltip mouseovers (PFUI issue with sticking icon + font size)
- Revised Description window, more in line with WoW interface
- Description panel now Profile window, has Mouseover and Target information as well
- Ability to select and fetch in directory, delete in directory
- Clicking in directory opens new Profile window
- Personal notes now collected in Profile window
- Ability to set RP Style in Admin Profile RP Style tab
- RP style shows in Profile window

Beta fixes
- Removing any quotation verification from chat-line emote; only present on chat box emote verification
- Otherwise, chat line emotes are reset with every press so errors do not continue after typos
- No validation error should appear for other players anymore
- NOTE: if a link is included in the text, and you are using Shagu / PFUI, the text will be mis-formatted because Shagu adds a white color after a link
- Validation checking for "~", "°", or "§" in any saved text
- No longer possible to save characters above, so users should never see them in their own profile (requires a new save to validate, will not work if user already has these characters in the profile)
- "%" character now allowed in emotes
- Hiding map icons correctly when changing frames on world map
  - TEST: possible error with characters on different continents, then moving back to your own continent, players misaligned on map
- Removed edges from Dark UI Description
- Titles on descriptions no longer replaced when new "Glances" open
- Data "sends" will now use "p" as the character name (just a placeholder for 'player'); using message sender instead, more reliable
- Mechanisms for cleaning directory (removing players with bad characters)
- Mechanism to delete single player from directory (manually remove characters as desired)

1.0.1 (not released)

- No more drunk texting
- TurtleRP_ChatBox now visible in RP mode
- Longer description
- Longer notes

1.0.0 same as 0.1.4

0.1.4

- Minor fix to highlighted icon when opening admin
- Storing script and redoing on world frame (focus clear)
- Prevent messages sending when under level 5, or when AFK
- Fix to scrolling description frame
- Fix to target and wrong name appearing when message sent in chat bug

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
