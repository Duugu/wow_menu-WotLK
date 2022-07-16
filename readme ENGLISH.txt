Release: 2.12

IMPORTANT SET UP STEPS. DO THIS:
1. Copy the folder "wow_menu" from the downloaded .zip file to some local location on your computer.
2. Go to the folder "wow_menu" that you've just copied.
3. (Optional) Create a shortcut to the appropiate script (wow-menu_EN_EU.ahk or wow-menu_EN_US.ahk, depending on your language/region combination) on you desktop, to easily start the script if you start playing the game.
4. Go to the folder "CopyTheContentOfThisFolderToInterface" in you "wow_menu" folder. There should be 3 folders in there.
5. Copy all 3 folders ("DialogFrame", "GLUES", "HELPFRAME").
6. Go to the "Interface" folder ("C:\Program Files (x86)\World of Warcraft\_classic_\Interface").
7. Insert the just copied 3 folders in that "Interface" folder.
8. You are done!
Caution: You need to really carefully follow the instructions above. Do NOT just copy the full "wow_menu" folder from the downloaded .zip file to "Interface". That won't work.

----------------------------------------------------------------------------------------

1. What is the script doing?

The script has two modes: "Login" and "Play". You can switch between them with ALT + F1.
In "Login" mode, you can select characters and enter the game world with them, create new characters, switch to another server or delete characters.
In "Play" mode, you can use the NUMPAD 7-8 keys to do right-clicks at tree different positions in the game. This function is used for looting in the game.
Use ALT + ESCAPE to unload/end the script (there's no audio feedback on that action!).

2. Usage

Start the script by launching the correct file for your language and region:
- If you are playing on US servers: wow-menu_EN_US.ahk
- If you are playing on EU servers in English: wow-menu_EN_EU.ahk
- If you are playing on EU servers in German: wow-menu_DE_EU.ahk
The script starts in "Login" mode. It gets active only after you started WoW and the WoW window gets the focus.
Then it tries to detect the character selection page, or it waits until you are logged in to WoW and the character selection page is loaded. As long as the script is doing any recognition or waits, you will hear a sound. The sound means that you have to wait.
Don't press any key, don't switch the window and don't do anything else while the sound is playing. Never. Nowhere in the menu. Raise your hands in the air while the sound is playing.
Once you get to the character selection page, the audio menu opens. It says "Main Menu." You can navigate to the submenu with options using the RIGHT ARROW key. The use DOWN and UP keys to choose menu options in that submenu.
To log in with a character, you first need to select that character, and then log in with the selected character.
There are no character names recognized or read out. The script only reads "1, 2, 3 to 10" for the character slots. You have to remember what character is in each slot (just take a note for every new character you're creating).
Newly created chars always end up in the next free slot. If you already have 3 characters and you create a new one, it will be in slot 4.
After logging in, the script automatically switches to "Play" mode. When logging out it automatically switches to "Login" mode. If that doesn't work, you can use ALT + F1 to manually switch.

3. Requirements:

- The script is only working with WoW TBC on Windows. No Mac, no Retail.
- Do not move the script file and its folder. Create a shortcut to the script file, if you would like to access it more easily.
- The script requires that you are playing in fullscreen mode. (This is the default).
- The script requires the same screen resolution in WoW as the Windows screen resolution is (this is the default).

----------------------------------------------------------------------------------------

RELEASE NOTES

Todo/bugs:
	- add server type to server names

Release notes:
	2.11
		- Numpad 9 has been changed. It now is turning your character towards the current beacon.
			The I key is and an alternative key bind for numpad 9.
		- Control + Shift + I / O / P have been removed as alternative keys for numpad 7, 8, 9.

	2.10
		- Added a "Delete character" menu option. 
			The character in the currently selected slot will be deleted. 
			All characters below the deleted character will be moved one slot up.
		- Added a voice output to script termination.
		- Fixed a bug with unusual portrait screen resolutions like 1250 x 1440 (width/height ratio <1). Script should now recognize login mode with those resolutions.

	2.9
		- Changed the alternative key binds for the numpad 7-9 from Shift to Ctrl + Shift:
			Control + Shift + I for numpad 7
			Control + Shift + O for numpad 8
			Control + Shift + P for numpad 9


	2.8
		- Added alternative key binds for the numpad 7-9 feature:
			Shift + I for numpad 7
			Shift + O for numpad 8
			Shift + P for numpad 9
		- Fixed an issue with switching realm at 1024x768 resolution

	2.5
		- Re-designed the script to be more reliable and much faster.
		- The script stops auto switching between gaming/login mode if you do use ALT + F1 to manually switch the mode. You need to restart the script to turn auto switching on again.
		- Changed the "script is processing" sound to something (water drop) that is better to hear is there's ingame music playing.
		- The script now is replacing a lot of textures on login and char selection screens. If a sighted person asks why the UI looks that "broken", that is the reason. It's a feature, not a bug.

	1.7
		- Added addition gaming mode detection pixel at lower left corner of the screen, just in case that the upper left corner is covered by overlays from streaming software (requires Sku r25.9).
		- Optimized the detection. Script shouldn't unintentionally click on "Delete character" anymore.

	1.6
		- Added English TTS audio data
		- Added EN EU and EN US region / realm lists
		- Splitted the script into separate script for EN_EU, EN_US, DE_EU.
		- Optimized the recognition of "Login" and "Game" mode
		- Fixed a bunch of issues with mode detection

	1.5
		- fixed an issue with not working enter key in menus after char creation

	1.4
		- the script is not anymore incorrectly detecting anything with the string "World of Warcraft" in a window title as the game window

	1.3
		- the volume of the "load" sound was decreased
		- new output "paused" if the wow window lost the focus
		- script now automatically detects and switches the mode (login, play, paused); ctrl + f1 to manually switch modes is still available, but shouldn't be required anymore

	1.2
		- new shortcut alt + esc to exit the script
		- script stops all activies in login mode and switches to play mode if wow has lost the focus.
		- script ignores arrow, enter, and esc keys if wow hasn't the focus

	1.1
		- hotkey to switch modes changed from numpadsub to alt+f1
		- script now considers all 10 character slots per server instead of 9
		- numpad8 testing keybind removed
		- testing tooltip removed
		- code cleanup
