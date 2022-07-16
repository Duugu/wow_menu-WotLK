Release: 2.12

WICHTIGE EINRICHTUNGSSCHRITTE. GEHE FOLGENDERMAßEN VOR:
1. Kopiere den Ordner "wow_menu" aus der heruntergeladenen Zip-Datei in einen beliebigen Ordner auf deinem Computer. 
2. Geh zum gerade eingefügten Ordner "wow_menu".
3. (Optional) Erstelle eine Verknüpfung zum entsprechenden Skript (wow-menu_DE_EU.ahk, wow-menu_EN_EU.ahk oder wow-menu_EN_US.ahk, je nach deiner Kombination aus Sprache und Region) auf deinem Desktop. Damit kannst du das Skript später einfacher zum Spielen starten.
4. Geht zum Ordner "CopyTheContentOfThisFolderToInterface" in deinem "wow_menu" Ordner. Er enthält 3 Ordner.
5. Kopiere alle 3 Ordner ("DialogFrame", "GLUES", "HELPFRAME").
6. Geht zum "Interface" Ordner ("C:\Program Files (x86)\World of Warcraft\_classic_\Interface").
7. Füge die soeben kopierten 3 Ordner in diesem "Interface"-Ordner ein.
8. Das war's!
Achtung: Du musst die Anweisungen oben zwingend genau befolgen. Kopiere NICHT einfach den gesamten "wow_menu"-Ordner aus der heruntergeladenen Zip-Datei in den "Interface"-Odner. Das Skript funktioniert dann nicht.

1. Was macht das Skript?

Das Skript hat zwei Modi: "Login" und "Spielen", zwischen denen du mit ALT + F1 umschalten kannst.
Im Modus "Login" kannst du über ein Audio-Menü auf der Charakterauswahl-Seite von WoW Chars auswählen und mit diesen die Spielwelt betreten, neue Chars erstellen, zu einem anderen Server wechseln oder Chars löschen.
Im Modus "Spielen" kannst du über die Tasten NUMMERNBLOCK 7-8 zwischen drei Kameraperspektiven im Spiel umschalten und gleichzeitig einen Rechtsklick im Spiel durchführen. Diese Funktion dient dem Plündern im Spiel.
Mit ALT + ESCAPE kannst du das Skript vollständig beenden (es gibt kein Audiofeedback dabei!).

2. Verwendung

Du startest das Skript indem du die Datei für deine Sprache und Region ausführst:
- Wenn du auf US-Servern spielst: wow-menu_EN_US.ahk
- Wenn du auf EU-Servern in English spielst: wow-menu_EN_EU.ahk
- Wenn du auf EU-Servern in Deutsch spielst: wow-menu_DE_EU.ahk
Das Skript startet im Modus "Login". Es wird erst aktiv, wenn du WoW gestartet hast und das WoW-Fenster den Fokus bekommt.
Dann versucht es die Charauswahlseite zu erkennen, bzw. es warte so lange, bist du in WoW angemeldet bist und die Charakterauswahlseite geladen ist. Solange das Skript irgendeine Erkennung durchführt oder wartet, hörst du einen Sound. Der Sound bedeutet, dass du warten musst.
Achtung: Drücke keine Taste, wechsel nicht das Fenster und mach keine anderen Dinge solange der Sound läuft. Niemals. Nirgendwo im Menü. Selbst dann nicht, wenn sonst die Welt untergeht. Hebe deine Hände in die Luft, solange der Sound läuft.
Sobald du auf der Charakterauswahlseite angekommen bist, öffnet sich das Audio-Menü. Es sagt "Hauptmenü". Du kannst im Menü nach rechts gehen, und die einzelnen Optionen verwenden.
Wenn du dich mit einem Char einloggen möchtest, musst du diesen erst auswählen und dich dann mit dem ausgewählen Char einloggen.
Charkternamen werden dabei nicht erkannt oder vorgelesen. Dir wird nur "1, 2, 3 bis 10" für die Charakterplätze vorgelesen. Was sich für ein Char auf dem jeweiligen Platz befindet musst du dir selbst notieren.
Neu erstellte Chars landen immer auf dem nächsten freien Platz. Wenn du also schon 3 Chars hast, und einen neuen erstellst, dann ist dieser auf Platz 4.
Nach dem Einloggen schaltet das Skript automatisch auf "Spielen". Beim Ausloggen schaltet es automatisch auf "Login". Sollte das nicht funktionieren, kannst du mit ALT + F1 selbst umschalten.

3. Voraussetzungen:

- Das Skript funktioniert nur unter Windows, nur mit WoW TBC und nur mit dem deutschen WoW-Client.
- Du darfst das Skript und seinen Ordner nicht verschieben. Wenn du es einfacher starten möchtest, kannst du dir eine Verknüpfung zu deinem Skript erstellen.
- Das Skript erfordert, dass du WoW im Vollbildmodus spielst. (Das ist standardmäßig so.)
- Das Skript erfordert, dass du in WoW dieselbe Auflösung wie in Windows verwendest (das ist standardmäßig so).

----------------------------------------------------------------------------------------

Todo/Bugs:
	- Serverarten zu den Namen hinzufügen.

Veröffentlichungshinweise:
	2.11
		- Nummernblock 9 wurde geändert. Diese Taste dient nun dazu deinen Char in die Richtung des aktuellen Beacons zu drehen.
			Die Taste I ist eine alternative Taste für Nummernblock 9 (falls du eine Tastatur ohne Nummernblock hast).
			Nummernblock 7 und 8 behalten die alte Funktion. (Rechtsklick in die Spielwelt.)
		- Steuerung + Shift + I / O / P als alternative Tastenbelegung für Nummernblock 7, 8, 9 wurden ersatzlos gestrichen.

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
