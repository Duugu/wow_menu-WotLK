/*
Release: 2.12
*/

;------------------------------------------------------------------------------------------
; ahk settings
;------------------------------------------------------------------------------------------
#Persistent
#MaxThreadsPerHotkey 2 ;we need that for NumpadSub; without at least 2 threads it won't be able to interupt itself to switch modes while the select mode is scanning for the char selection screen
#SingleInstance Force
#NoEnv
SendMode Input
SetWorkingDir %A_ScriptDir%

gosub InitMenu
SetTimer, CheckMode, 1000

;------------------------------------------------------------------------------------------
; globals
;------------------------------------------------------------------------------------------
global gManualOverride := false

global gCurrentMenuItem
global gMainMenu

global gNumberOfCharsOnCurrentRealm := -1
global gCharUIPositions
global gEnterCharacterNameFlag := false
global gDeleteCharacterNameFlag := false

global gIgnoreKeyPress := false

global gIsInitializing
global gIsChecking

global tPopupClosed

global Mode := -1

SwitchToMode_1()

;------------------------------------------------------------------------------------------
;generic class for menu entries
;------------------------------------------------------------------------------------------
class baseMenuEntryObject
{
    name := "generic Name"
    parent := ""
    p := ""
    n := ""
    childs := []

    onSelect()
    {
		if (this.childs not or this.childs.MaxIndex() < 1)
		{
			PlayUtterance(this.name)
			return
		}
		this.childs[1].onEnter()
    }

    onEnter()
    {
		gCurrentMenuItem := this
		PlayUtterance(this.name)
    }

	onAction()
	{
		;MsgBox % this.name " generic"
	}
}

;------------------------------------------------------------------------------------------
; general keybinds, subs, functions
;------------------------------------------------------------------------------------------
!Esc::
	PlayUtterance("script_exited")
	sleep 1000
	ExitApp
return

;------------------------------------------------------------------------------------------
!f1::
	Thread, Interrupt, 0

	gManualOverride := true

	if(Mode = 1 or Mode = -1)
	{
		SwitchToMode0()
	}
	else if(Mode = 0)
	{
		SwitchToMode1()
		InitLogin()
	}
return

;------------------------------------------------------------------------------------------
CheckMode:
	if(gIsChecking = true)
	{
		return
	}

	gIsChecking := true

	if(gManualOverride = true)
	{
		return
	}

	if(gIsInitializing = true)
	{
		return
	}

	if(IsWoWWindowFocus() != true and Mode != -1)
	{
		SwitchToMode_1()
	}
	else
	{
		if(IsIngame() = true and Mode != 0)
		{
			SwitchToMode0()
		}
		else if(Mode != 1 and IsGlue() = true)
		{
			SwitchToMode1()
			if(gIsInitializing != true)
			{
				InitLogin()
			}
		}
	}

	gIsChecking := false
return

;------------------------------------------------------------------------------------------
InitLogin()
{
	gIsInitializing := true

	StartOver:

	if(IsCharSelectionScreen() = true)
	{
		if(IsDeleteCharPopup() = true)
		{
			tmpScreen := UiToScreenNEW(10195, 437)
			MouseMove, floor(tmpScreen.X), floor(tmpScreen.Y), 0
			Send {Click}
		}

		tTimeout := 0
		while(IsCharSelectionScreen() = true and (Is11Popup() = true or Is12Popup() = true))
		{
			gosub CheckMode
			if(Mode != 1)
			{
				return
			}

			ClosePopUps()

			tTimeout := tTimeout + 1
			WaitForX(1, 500)
			if(tTimeout > 60)
			{
				PlayUtterance("fail_connection_restart")
				sleep 2000
				gIgnoreKeyPress := false
				SwitchToMode_1()
				Pause
				return
			}
		}

		gosub CheckMode
		if(Mode != 1)
		{
			return
		}

		UpdateCharacterMenu()

		gosub CheckMode
		if(Mode != 1)
		{
			return
		}

		gCurrentMenuItem := gMainMenu
		gMainMenu.onEnter()
	}
	else if(IsLoginScreen() = true)
	{
		tPopupClosed := false

		tTimeout := 0
		while(IsLoginScreen() = true)
		{
			gosub CheckMode
			if(Mode != 1)
			{
				return
			}

			tTimeout := tTimeout + 1
			WaitForX(1, 500)
			if(tTimeout > 120)
			{
				PlayUtterance("fail_connection_restart")
				sleep 2000
				gIgnoreKeyPress := false
				SwitchToMode_1()
				Pause
			return
			}


			if(IsLoginScreenInitialStart() != true)
			{
				ClosePopUps()

				if(IsReconnect() = true)
				{
					;click on reconnect
					;MsgBox Reconnect
					tPopupClosed := true
					tmpScreen := UiToScreenNEW(9917, 441)
					MouseMove, floor(tmpScreen.X), floor(tmpScreen.Y), 0
					Send {Click}
				}
			}
		}
	}
	else if(IsRealmSelectionScreen() = true)
	{
		tmpScreen := UiToScreenNEW(-403, 606)
		MouseMove, floor(tmpScreen.X), floor(tmpScreen.Y), 0
		Send {Click} ;cancel

		tTimeout := 0
		while(IsRealmSelectionScreen() = true)
		{
			gosub CheckMode
			if(Mode != 1)
			{
				return
			}

			tTimeout := tTimeout + 1
			WaitForX(1, 500)
			if(tTimeout > 60)
			{
				PlayUtterance("fail_connection_restart")
				sleep 2000
				gIgnoreKeyPress := false
				SwitchToMode_1()
				Pause
			return
			}
		}
	}
	else if(IsCharCreationScreen() = true)
	{
		tmpScreen := UiToScreenNEW(-72, 733)
		MouseMove, floor(tmpScreen.X), floor(tmpScreen.Y), 0
		Send {Click} ;back

		tTimeout := 0
		while(IsCharCreationScreen() = true)
		{
			gosub CheckMode
			if(Mode != 1)
			{
				return
			}

			tTimeout := tTimeout + 1
			WaitForX(1, 500)
			if(tTimeout > 60)
			{
				PlayUtterance("fail_connection_restart")
				sleep 2000
				gIgnoreKeyPress := false
				SwitchToMode_1()
				Pause
			return
			}
		}
	}

	if(IsCharSelectionScreen() != true)
	{
		gosub CheckMode
		if(Mode != 1)
		{
			return
		}
		goto, StartOver
		;InitLogin()
	}
	else if(gNumberOfCharsOnCurrentRealm = -1)
	{
		gosub CheckMode
		if(Mode != 1)
		{
			return
		}
		UpdateCharacterMenu()

		gosub CheckMode
		if(Mode != 1)
		{
			return
		}

		gCurrentMenuItem := gMainMenu
		gMainMenu.onEnter()
	}
	gIsInitializing := false
}

;------------------------------------------------------------------------------------------
ClosePopUps()
{
	if(Is11Popup() = true and tPopupClosed != true)
	{
		;click 1 line 1 button popup away
		;MsgBox 1L 1B
		tPopupClosed := true
		tmpScreen := UiToScreenNEW(9915, 397)
		MouseMove, floor(tmpScreen.X), floor(tmpScreen.Y), 0
		Send {Click}
		Sleep, 200
	}

	if(Is21Popup() = true and tPopupClosed != true)
	{
		;click 2 lines 1 button popup away
		;MsgBox 2L 1B
		tPopupClosed := true
		tmpScreen := UiToScreenNEW(9915, 405)
		MouseMove, floor(tmpScreen.X), floor(tmpScreen.Y), 0
		Send {Click}
		Sleep, 200
	}

	if(Is12Popup() = true and tPopupClosed != true)
	{
		;click 1 line 2 buttons popup away
		;MsgBox 1L 2B
		tPopupClosed := true
		tmpScreen := UiToScreenNEW(10196, 397)
		MouseMove, floor(tmpScreen.X), floor(tmpScreen.Y), 0
		Send {Click}
		Sleep, 200
	}

	if(Is22Popup() = true and tPopupClosed != true)
	{
		;click 2 lines 2 buttons popup away (right button)
		;MsgBox 2L 2B
		tPopupClosed := true
		tmpScreen := UiToScreenNEW(10196, 405)
		MouseMove, floor(tmpScreen.X), floor(tmpScreen.Y), 0
		Send {Click}
		Sleep, 200
	}
}


;------------------------------------------------------------------------------------------
InitMenu:
	global gCharUIPositions := {1:{x:-45,y:106},2:{x:-45,y:162},3:{x:-45,y:218},4:{x:-45,y:274},5:{x:-45,y:330},6:{x:-45,y:386},7:{x:-45,y:442},8:{x:-45,y:498},9:{x:-45,y:554},10:{x:-45,y:610}}

	global tRealmLangs := {1:{name:"english",x:450,y:636},2:{name:"german",x:9827,y:636},3:{name:"french",x:9899,y:636},4:{name:"spanish",x:9988,y:636}}

	global tServerNames := {}
	tServerNames[1] := {1:{name:"Ashbringer",x:9795,y:192},2:{name:"Bloodfang",x:9795,y:212},3:{name:"Dragonfang",x:9795,y:232},4:{name:"Dreadmist",x:9795,y:252},5:{name:"Earthshaker",x:9795,y:272},6:{name:"Firemaw",x:9795,y:292},7:{name:"Flamelash",x:9795,y:312},8:{name:"Gandling",x:9795,y:332},9:{name:"Gehennas",x:9795,y:352},10:{name:"Golemagg",x:9795,y:372},11:{name:"Hydraxian_Waterlords",x:9795,y:392},12:{name:"Judgement",x:9795,y:412},13:{name:"Mirage_Raceway",x:9795,y:432},14:{name:"Mograine",x:9795,y:452},15:{name:"Nethergarde_Keep",x:9795,y:472},16:{name:"Noggenfogger",x:9795,y:492},17:{name:"Pyrewood_Village",x:9795,y:512},18:{name:"Razorgore",x:9795,y:532},19:{name:"Shazzrah",x:9795,y:552},20:{name:"Skullflame",x:9795,y:572}}
	tServerNames[2] := {1:{name:"celebras",x:9795,y:192},2:{name:"dragons_call",x:9795,y:212},3:{name:"everlook",x:9795,y:232},4:{name:"heartstriker",x:9795,y:252},5:{name:"lakeshire",x:9795,y:272},6:{name:"lucifron",x:9795,y:292},7:{name:"patchwerk",x:9795,y:312},8:{name:"razorfen",x:9795,y:332},9:{name:"transcendence",x:9795,y:352},10:{name:"venoxis",x:9795,y:372}}
	tServerNames[3] := {1:{name:"Amnennar",x:9795,y:192},2:{name:"Auberdine",x:9795,y:212},3:{name:"Finkle",x:9795,y:232},4:{name:"Sulfuron",x:9795,y:252}}
	tServerNames[4] := {1:{name:"Mandokir",x:9795,y:192}}

	global tGenders := {1:{name:"male",x:102,y:420},2:{name:"female",x:146,y:420}}
	global tRaces := {1:{name:"human",x:81,y:150,classes:{1:"warrior",2:"paladin",3:"rogue",4:"priest",5:"mage",6:"warlock"}},2:{name:"dwarf",x:81,y:202,classes:{1:"warrior",2:"paladin",3:"hunter",4:"rogue",5:"priest"}},3:{name:"nightelf",x:81,y:254,classes:{1:"warrior",2:"hunter",3:"rogue",4:"priest",5:"druid"}},4:{name:"gnome",x:81,y:306,classes:{1:"warrior",2:"rogue",3:"mage",4:"warlock"}},5:{name:"draenei",x:81,y:358,classes:{1:"warrior",2:"paladin",3:"hunter",4:"priest",5:"shaman",6:"mage"}},6:{name:"orc",x:177,y:150,classes:{1:"warrior",2:"hunter",3:"rogue",4:"shaman",5:"warlock"}},7:{name:"undead",x:177,y:202,classes:{1:"warrior",2:"rogue",3:"priest",4:"mage",5:"warlock"}},8:{name:"tauren",x:177,y:254,classes:{1:"warrior",2:"hunter",3:"shaman",4:"druid"}},9:{name:"troll",x:177,y:306,classes:{1:"warrior",2:"hunter",3:"rogue",4:"priest",5:"shaman",6:"mage"}},10:{name:"bloodelf",x:177,y:358,classes:{1:"paladin",2:"hunter",3:"rogue",4:"priest",5:"mage",6:"warlock"}}}

	;build the audio menu
	;main
	gMainMenu := new baseMenuEntryObject
	gMainMenu.name := "main_menu"
	gMainMenu.parent := ""
	gMainMenu.childs := []

		;menu item 1
		tMainItemN := 1
		gMainMenu.childs[tMainItemN] := new baseMenuEntryObject
		gMainMenu.childs[tMainItemN].parent := gMainMenu
		gMainMenu.childs[tMainItemN].name := "select_char"
		;UpdateCharacterMenu()

		;menu item 2
		tMainItemN := 2
		gMainMenu.childs[tMainItemN] := new baseMenuEntryObject
		gMainMenu.childs[tMainItemN].parent := gMainMenu
		gMainMenu.childs[tMainItemN].name := "login_with_selected_char"
		gMainMenuchilds2Action(this){
			tRGBColor := GetColorAtUiPos(9918, 705)
			if (IsColorRange(tRGBColor.r, 139) = true and IsColorRange(tRGBColor.g, 139) = true and IsColorRange(tRGBColor.b, 139) = true)
			{
				gMainMenu.childs[1].onEnter()
			}
			else
			{
				tmp := UiToScreenNEW(9918, 700)
				MouseMove, tmp.X, tmp.Y, 0
				Send {Click}
			}
		}
		gMainMenu.childs[tMainItemN].onAction := Func("gMainMenuchilds2Action").Bind(gMainMenu.childs[tMainItemN])

		;menu item 3
		tMainItemN := 3
		gMainMenu.childs[tMainItemN] := new baseMenuEntryObject
		gMainMenu.childs[tMainItemN].parent := gMainMenu
		gMainMenu.childs[tMainItemN].name := "create_char"
		gMainMenu.childs[tMainItemN].childs := []
			Loop, 2
			{
				tGenderNumber := A_Index
				gMainMenu.childs[tMainItemN].childs[tGenderNumber] := new baseMenuEntryObject
				gMainMenu.childs[tMainItemN].childs[tGenderNumber].parent := gMainMenu.childs[tMainItemN]
				gMainMenu.childs[tMainItemN].childs[tGenderNumber].name := tGenders[tGenderNumber].name
				gMainMenu.childs[tMainItemN].childs[tGenderNumber].childs := []
				Loop % tRaces.MaxIndex()
				{
					tRaceNumber := A_Index
					gMainMenu.childs[tMainItemN].childs[tGenderNumber].childs[tRaceNumber] := new baseMenuEntryObject
					gMainMenu.childs[tMainItemN].childs[tGenderNumber].childs[tRaceNumber].parent := gMainMenu.childs[tMainItemN].childs[tGenderNumber]
					gMainMenu.childs[tMainItemN].childs[tGenderNumber].childs[tRaceNumber].name := tRaces[tRaceNumber].name
					gMainMenu.childs[tMainItemN].childs[tGenderNumber].childs[tRaceNumber].childs := []
					Loop % tRaces[tRaceNumber].classes.MaxIndex()
					{
						tClassNumber := A_Index
						gMainMenu.childs[tMainItemN].childs[tGenderNumber].childs[tRaceNumber].childs[tClassNumber] := new baseMenuEntryObject
						gMainMenu.childs[tMainItemN].childs[tGenderNumber].childs[tRaceNumber].childs[tClassNumber].parent := gMainMenu.childs[tMainItemN].childs[tGenderNumber].childs[tRaceNumber]
						gMainMenu.childs[tMainItemN].childs[tGenderNumber].childs[tRaceNumber].childs[tClassNumber].name := tRaces[tRaceNumber].classes[tClassNumber]
						gMainMenuchildsGenericCreateCharAction(this, genderNumber, raceNumber, classNumber)
						{
							gNumberOfCharsOnCurrentRealm := GetNumberOfChars()

							if(gNumberOfCharsOnCurrentRealm < 9)
							{
								gIgnoreKeyPress := true
								tmp := UiToScreenNEW(-230, 616)
								MouseMove, tmp.X, tmp.Y, 0
								Send {Click}

								;wait for create screen
								tTimeout := 0
								while(IsCharCreationScreen() != true)
								{
									gosub CheckMode
									if(Mode != 1)
									{
										return
									}

									tTimeout := tTimeout + 1
									WaitForX(1, 500)
									if(tTimeout > 60)
									{
										PlayUtterance("fail_connection_restart")
										sleep 2000
										gIgnoreKeyPress := false
										SwitchToMode_1()
										Pause
									return
									}
								}

								tmp := UiToScreenNEW(tRaces[raceNumber].x, tRaces[raceNumber].y)
								MouseMove, tmp.X, tmp.Y, 0
								Send {Click}
								WaitForX(2, 500)

								tClassPositions := {1:{x:84,y:476},2:{x:135,y:476},3:{x:181,y:476},4:{x:87,y:520},5:{x:133,y:520},6:{x:181,y:520}}
								tmp := UiToScreenNEW(tClassPositions[classNumber].x, tClassPositions[classNumber].y)
								MouseMove, tmp.X, tmp.Y, 0
								Send {Click}
								WaitForX(2, 500)

								tmp := UiToScreenNEW(tGenders[genderNumber].x, tGenders[genderNumber].y)
								MouseMove, tmp.X, tmp.Y, 0
								Send {Click}
								WaitForX(2, 500)

								;random style
								tmp := UiToScreenNEW(90, 737)
								MouseMove, tmp.X, tmp.Y, 0
								Send {Click}

								;enter char name and press enter or esc to abort
								gEnterCharacterNameFlag := true

								PlayUtterance("enter_name_press_enter_or_esc")

								gIgnoreKeyPress := false
							}
							else
							{
								PlayUtterance("max_chars_on_server")
							}
							gIgnoreKeyPress := false

						}
						gMainMenu.childs[tMainItemN].childs[tGenderNumber].childs[tRaceNumber].childs[tClassNumber].onAction := Func("gMainMenuchildsGenericCreateCharAction").Bind(gMainMenu.childs[tMainItemN].childs[tGenderNumber].childs[tRaceNumber].childs[tClassNumber], tGenderNumber, tRaceNumber, tClassNumber)
					}
					UpdateChilds(gMainMenu.childs[tMainItemN].childs[tGenderNumber].childs[tRaceNumber])
				}
				UpdateChilds(gMainMenu.childs[tMainItemN].childs[tGenderNumber])
			}
			;we need to run the helper UpdateChilds once for every new sub menu, to set up prev/next menu item for all menu items on the given menu level
			UpdateChilds(gMainMenu.childs[tMainItemN])

		;menu item 4
		tMainItemN := 4
		gMainMenu.childs[tMainItemN] := new baseMenuEntryObject
		gMainMenu.childs[tMainItemN].parent := gMainMenu
		gMainMenu.childs[tMainItemN].name := "switch_server"
		gMainMenu.childs[tMainItemN].childs := []
			Loop % tRealmLangs.MaxIndex()
			{
				tLangNumber := A_Index
				gMainMenu.childs[tMainItemN].childs[tLangNumber] := new baseMenuEntryObject
				gMainMenu.childs[tMainItemN].childs[tLangNumber].parent := gMainMenu.childs[tMainItemN]
				gMainMenu.childs[tMainItemN].childs[tLangNumber].name := tRealmLangs[tLangNumber].name
				;if(tLangNumber = 2)
				;{
				gMainMenu.childs[tMainItemN].childs[tLangNumber].childs := []
					Loop % tServerNames[tLangNumber].MaxIndex()
					{
						tRealmNumber := A_Index
						gMainMenu.childs[tMainItemN].childs[tLangNumber].childs[tRealmNumber] := new baseMenuEntryObject
						gMainMenu.childs[tMainItemN].childs[tLangNumber].childs[tRealmNumber].parent := gMainMenu.childs[tMainItemN].childs[tLangNumber ]
						gMainMenu.childs[tMainItemN].childs[tLangNumber].childs[tRealmNumber].name := tServerNames[tLangNumber][tRealmNumber].name
						gMainMenuchilds4ChildsXChildsYAction(this, langNumber, serverNumber)
						{
							gIgnoreKeyPress := true

							PlayUtterance("switching_to_server")
							sleep 1500

							;test if on char selection screen
							if(IsCharSelectionScreen() != true)
							{
								;if not > init to char sel
								;Send {Esc}
								InitLogin()
							}

							;click on "select realm"
							tmp := UiToScreenNEW(-191, 51)
							MouseMove, tmp.X, tmp.Y, 0
							Send {Click}

							;wait for realm selection screen
							tTimeout := 0
							while(IsRealmSelectionScreen() != true)
							{
								gosub CheckMode
								if(Mode != 1)
								{
									return
								}

								tTimeout := tTimeout + 1
								WaitForX(1, 500)
								if(tTimeout > 60)
								{
									PlayUtterance("fail_connection_restart")
									sleep 2000
									gIgnoreKeyPress := false
									SwitchToMode_1()
									Pause
								return
								}
							}

							;click on lang tab
							tmp := UiToScreenNEW(tRealmLangs[langNumber].x, tRealmLangs[langNumber].y)
							MouseMove, tmp.X, tmp.Y, 0
							Send {Click}

							WaitForX(1, 500)
							;click on sort by type
							tmp := UiToScreenNEW(9985, 168)
							MouseMove, tmp.X, tmp.Y, 0
							Send {Click}

							WaitForX(1, 500)
							;click on sort by name
							tmp := UiToScreenNEW(9935, 168)
							MouseMove, tmp.X, tmp.Y, 0
							Send {Click}

							WaitForX(1, 500)
							;click on server
							tmp := UiToScreenNEW(tServerNames[langNumber][serverNumber].x,tServerNames[langNumber][serverNumber].y)
							MouseMove, tmp.X, tmp.Y, 0
							;MsgBox % tLangNumber . " - " . serverNumber . " - " . tServerNames[tLangNumber][serverNumber].x . " - " . tServerNames[tLangNumber][serverNumber].x . " - " . tmp.X . " - " . tmp.Y
							Send {Click}



							WaitForX(1, 500)
							;click on ok
							tmp := UiToScreenNEW(10081, 606)
							MouseMove, tmp.X, tmp.Y, 0
							Send {Click}

							WaitForX(4, 500)
							if(IsHighPopServerWarning() = true)
							{
								tmp := UiToScreenNEW(9810, 436)
								MouseMove, tmp.X, tmp.Y, 0
								Send {Click}
								WaitForX(1, 500)
							}

							;test if on char selection screen
							tTimeout := 0
							while(IsCharSelectionScreen() != true)
							{
								gosub CheckMode
								if(Mode != 1)
								{
									return
								}

								if(IsCharCreationScreen() = true)
								{
									;not chars > back to char sel
									tmp := UiToScreenNEW(-72, 733)
									MouseMove, tmp.X, tmp.Y, 0
									Send {Click}
									WaitForX(1, 500)
								}

								tTimeout := tTimeout + 1
								WaitForX(1, 500)
								if(tTimeout > 60)
								{
									PlayUtterance("fail_connection_restart")
									sleep 2000
									gIgnoreKeyPress := false
									SwitchToMode_1()
									Pause
								return
								}
							}

							;update number of characters
							UpdateCharacterMenu()

							PlayUtterance("switched_to_Server")
							sleep 1200

							;jump to char selection
							gMainMenu.childs[1].onEnter()

							gIgnoreKeyPress := false
						}
						gMainMenu.childs[tMainItemN].childs[tLangNumber].childs[tRealmNumber].onAction := Func("gMainMenuchilds4ChildsXChildsYAction").Bind(gMainMenu.childs[tMainItemN].childs[tLangNumber].childs[tRealmNumber], tLangNumber, tRealmNumber)
					}
				UpdateChilds(gMainMenu.childs[tMainItemN].childs[tLangNumber])
				;}
			}
			UpdateChilds(gMainMenu.childs[4])

		;menu item 5
		tMainItemN := 5
		gMainMenu.childs[tMainItemN] := new baseMenuEntryObject
		gMainMenu.childs[tMainItemN].parent := gMainMenu
		gMainMenu.childs[tMainItemN].name := "delete_char"
		gMainMenuchilds5Action(this){
			tRGBColor := GetColorAtUiPos(-280, 724)
			;MsgBox % tRGBColor.r tRGBColor.g tRGBColor.b
			if (IsColorRange(tRGBColor.r, 255) = true and IsColorRange(tRGBColor.g, 0) = true and IsColorRange(tRGBColor.b, 0) = true)
			{
				;gMainMenu.childs[5].onEnter()
				;enter char name and press enter or esc to abort
				tmp := UiToScreenNEW(-280, 724)
				MouseMove, tmp.X, tmp.Y, 0
				Send {Click}

				gDeleteCharacterNameFlag := true
				PlayUtterance("enter_delete_and_press_enter_or_esc_to_cancel")
				gIgnoreKeyPress := false
			}
		}
		gMainMenu.childs[tMainItemN].onAction := Func("gMainMenuchilds5Action").Bind(gMainMenu.childs[tMainItemN])

		UpdateChilds(gMainMenu)

	;gCurrentMenuItem = gMainMenu
	;gMainMenu.onEnter()

	gIgnoreKeyPress := false
return

;------------------------------------------------------------------------------------------
; Checks
;------------------------------------------------------------------------------------------

IsColorRange(aTestColorValue, aCompareColorValue)
{
	if(aTestColorValue >= (aCompareColorValue - 2) and aTestColorValue <= (aCompareColorValue + 2))
	{
		return true
	}
	else
	{
		return false
	}
}

IsWoWWindowFocus()
{
	rReturnValue := false
	SetTitleMatchMode, 3
	If(WinActive("World of Warcraft"))
	{
		rReturnValue := true
	}

	return rReturnValue
}

;------------------------------------------------------------------------------------------
IsIngame()
{
	rReturnValue := false

	tmpUI := ScreenToUiNEW(1, 1)

	tRGBColor := GetColorAtUiPos(tmpUI.x, tmpUI.y)
	/*
	if (tRGBColor.r = 0 and tRGBColor.g = 0 and tRGBColor.b = 0)
	{
		rReturnValue := true
	}
	*/
	if (IsColorRange(tRGBColor.r, 0) = true and IsColorRange(tRGBColor.g, 0) = true and IsColorRange(tRGBColor.b, 255) = true)
	{
		rReturnValue := true
	}

	tmpUI := ScreenToUiNEW(1, A_ScreenHeight-2)

	tRGBColor := GetColorAtUiPos(tmpUI.x, tmpUI.y)
	/*
	if (tRGBColor.r = 0 and tRGBColor.g = 0 and tRGBColor.b = 0)
	{
		rReturnValue := true
	}
	*/
	if (IsColorRange(tRGBColor.r, 0) and IsColorRange(tRGBColor.g, 0) and IsColorRange(tRGBColor.b, 255))
	{
		rReturnValue := true
	}


	return rReturnValue
}

;------------------------------------------------------------------------------------------
IsGlue()
{
	rReturnValue := false

	if(IsLoginScreen() = true or IsCharSelectionScreen() = true or IsRealmSelectionScreen() = true or IsCharCreationScreen() = true)
	{
		rReturnValue := true
	}

	return rReturnValue
}

;------------------------------------------------------------------------------------------
IsLoginScreenInitialStart()
{
	gIgnoreKeyPress := true
	rReturnValue := false

	tRGBColorLogo := GetColorAtUiPos(38,72)
	tRGBColorQuit := GetColorAtUiPos(-23, 717)
	tRGBColorCreate := GetColorAtUiPos(28, 550)
	if ((IsColorRange(tRGBColorLogo.r, 198) = true and IsColorRange(tRGBColorLogo.g, 227) = true and IsColorRange(tRGBColorLogo.b, 0) = true) = true and (IsColorRange(tRGBColorQuit.r, 255) = true and IsColorRange(tRGBColorQuit.g, 0) = true and IsColorRange(tRGBColorQuit.b, 0) = true) = true and (IsColorRange(tRGBColorCreate.r, 255) = true and IsColorRange(tRGBColorCreate.g, 0) = true and IsColorRange(tRGBColorCreate.b, 0) = true) = false)
	{
		rReturnValue := true
	}

	gIgnoreKeyPress := false
	return rReturnValue
}

;------------------------------------------------------------------------------------------
IsLoginScreen()
{
	gIgnoreKeyPress := true
	rReturnValue := false

	tRGBColorLogo := GetColorAtUiPos(38,72)
	tRGBColorQuit := GetColorAtUiPos(-23, 717)
	if ((IsColorRange(tRGBColorLogo.r, 198) = true and IsColorRange(tRGBColorLogo.g, 227) = true and IsColorRange(tRGBColorLogo.b, 0) = true) and (IsColorRange(tRGBColorQuit.r, 255) = true and IsColorRange(tRGBColorQuit.g, 0) = true and IsColorRange(tRGBColorQuit.b, 0) = true))
	{
		rReturnValue := true
	}

	gIgnoreKeyPress := false
	return rReturnValue
}

;------------------------------------------------------------------------------------------
IsCharSelectionScreen()
{
	gIgnoreKeyPress := true
	rReturnValue := false

	tRGBColorLogo := GetColorAtUiPos(38,72)
	tRGBColorAddons := GetColorAtUiPos(49, 722)

	if ((IsColorRange(tRGBColorLogo.r, 198) = true and IsColorRange(tRGBColorLogo.g, 227) = true and IsColorRange(tRGBColorLogo.b, 0) = true) and (IsColorRange(tRGBColorAddons.r, 255) = true and IsColorRange(tRGBColorAddons.g, 0) = true and IsColorRange(tRGBColorAddons.b, 0) = true))
	{
		rReturnValue := true
	}

	gIgnoreKeyPress := false
	return rReturnValue
}

;------------------------------------------------------------------------------------------
IsCharCreationScreen()
{
	gIgnoreKeyPress := true
	rReturnValue := false

	tRGBColorLogo := GetColorAtUiPos(54, 11)
	tRGBColorRCBackdrop := GetColorAtUiPos(52, 417)
	if ((IsColorRange(tRGBColorLogo.r, 198) = true and IsColorRange(tRGBColorLogo.g, 227) = true and IsColorRange(tRGBColorLogo.b, 0) = true) and (IsColorRange(tRGBColorRCBackdrop.r, 0) = true and IsColorRange(tRGBColorRCBackdrop.g, 0) = true and IsColorRange(tRGBColorRCBackdrop.b, 0) = true))
	{
		rReturnValue := true
	}

	gIgnoreKeyPress := false
	return rReturnValue
}

;------------------------------------------------------------------------------------------
IsRealmSelectionScreen()
{
	gIgnoreKeyPress := true
	rReturnValue := false

	tRGBColorTitleBackdrop := GetColorAtUiPos(9952, 126)
	tRGBColorListBackdrop := GetColorAtUiPos(404, 145)
	if ((IsColorRange(tRGBColorTitleBackdrop.r, 0) = true and IsColorRange(tRGBColorTitleBackdrop.g, 56) = true and IsColorRange(tRGBColorTitleBackdrop.b, 0) = true) and (IsColorRange(tRGBColorListBackdrop.r, 40) = true and IsColorRange(tRGBColorListBackdrop.g, 0) = true and IsColorRange(tRGBColorListBackdrop.b, 0) = true))
	{
		rReturnValue := true
	}

	gIgnoreKeyPress := false
	return rReturnValue
}


;-----------------------------------------------------------------------------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------------------------------------------------------------------------
IsHighPopServerWarning()
{
	gIgnoreKeyPress := true
	rReturnValue := false

	tRGBColor := GetColorAtUiPos(9810, 436)
	if (IsColorRange(tRGBColor.r, 255) = true and IsColorRange(tRGBColor.g, 0) = true and IsColorRange(tRGBColor.b, 0) = true)
	{
		rReturnValue := true
	}

	gIgnoreKeyPress := false
	return rReturnValue
}

;------------------------------------------------------------------------------------------
IsDisconnected()
{
	gIgnoreKeyPress := true
	rReturnValue := false

	tRGBColor := GetColorAtUiPos(560,405)
	if (tRGBColor.r > 90 and tRGBColor.g < 40 and tRGBColor.b < 40)
	{
		rReturnValue := true
	}
	;MsgBox % rReturnValue
	gIgnoreKeyPress := false
	return rReturnValue
}
;-----------------------------------------------------------------------------------------------------------------------------------------------------
IsDeleteButtonEnabled()
{
	gIgnoreKeyPress := true
	rReturnValue := false

	tRGBColor := GetColorAtUiPos(9796, 437)
	if (IsColorRange(tRGBColor.r, 255) = true and IsColorRange(tRGBColor.g, 0) = true and IsColorRange(tRGBColor.b, 0) = true)
	{
		rReturnValue := true
	}

	gIgnoreKeyPress := false
	return rReturnValue
}
;-----------------------------------------------------------------------------------------------------------------------------------------------------
IsDeleteButtonDisabled()
{
	gIgnoreKeyPress := true
	rReturnValue := false

	tRGBColor := GetColorAtUiPos(9796, 437)
	if (IsColorRange(tRGBColor.r, 139) = true and IsColorRange(tRGBColor.g, 139) = true and IsColorRange(tRGBColor.b, 139) = true)
	{
		rReturnValue := true
	}

	gIgnoreKeyPress := false
	return rReturnValue
}
;-----------------------------------------------------------------------------------------------------------------------------------------------------
IsDeleteCancelButton()
{
	gIgnoreKeyPress := true
	rReturnValue := false

	tRGBColor := GetColorAtUiPos(10195, 437)
	if (IsColorRange(tRGBColor.r, 255) = true and IsColorRange(tRGBColor.g, 0) = true and IsColorRange(tRGBColor.b, 0) = true)
	{
		rReturnValue := true
	}

	gIgnoreKeyPress := false
	return rReturnValue
}
/*
;------------------------------------------------------------------------------------------
IsEnterCredentials()
{
	gIgnoreKeyPress := true
	rReturnValue := false

	tmyAccount := false

	tRGBColor := GetColorAtUiPos(32,590)
	if (tRGBColor.r > 190 and tRGBColor.g < 40 and tRGBColor.b < 40)
	{
		tmyAccount := true
	}

	tmp := UiToScreen(510,396)

	tRGBColor := GetColorAtUiPos(510.4,396)
	if (tRGBColor.r < 90 and tRGBColor.g < 90 and tRGBColor.b < 90 and tmyAccount = true)
	{
		rReturnValue := true
	}

	gIgnoreKeyPress := false
	return rReturnValue
}
*/

;------------------------------------------------------------------------------------------
Is12Popup()
{
	gIgnoreKeyPress := true
	rReturnValue := false

	tRGBColorLeft := GetColorAtUiPos(9802, 397)
	tRGBColorRight := GetColorAtUiPos(10196, 397)
	if((IsColorRange(tRGBColorLeft.r, 255) = true and IsColorRange(tRGBColorLeft.g, 0) = true and IsColorRange(tRGBColorLeft.b, 0) = true) and (IsColorRange(tRGBColorRight.r, 255) = true and IsColorRange(tRGBColorRight.g, 0) = true and IsColorRange(tRGBColorRight.b, 0) = true))
	{
		rReturnValue := true
	}

	gIgnoreKeyPress := false
	return rReturnValue
}
;------------------------------------------------------------------------------------------
Is22Popup()
{
	gIgnoreKeyPress := true
	rReturnValue := false

	tRGBColorLeft := GetColorAtUiPos(9802, 405)
	tRGBColorRight := GetColorAtUiPos(10196, 405)
	if((IsColorRange(tRGBColorLeft.r, 255) = true and IsColorRange(tRGBColorLeft.g, 0) = true and IsColorRange(tRGBColorLeft.b, 0) = true) and (IsColorRange(tRGBColorRight.r, 255) = true and IsColorRange(tRGBColorRight.g, 0) = true and IsColorRange(tRGBColorRight.b, 0) = true))
	{
		rReturnValue := true
	}

	gIgnoreKeyPress := false
	return rReturnValue
}
;------------------------------------------------------------------------------------------
Is11Popup()
{
	gIgnoreKeyPress := true
	rReturnValue := false

	tRGBColor := GetColorAtUiPos(9915, 397)
	if (IsColorRange(tRGBColor.r, 255) = true and IsColorRange(tRGBColor.g, 0) = true and IsColorRange(tRGBColor.b, 0) = true and Is12Popup() != true)
	{
		rReturnValue := true
	}

	gIgnoreKeyPress := false
	return rReturnValue
}
;------------------------------------------------------------------------------------------
Is21Popup()
{
	gIgnoreKeyPress := true
	rReturnValue := false

	tRGBColor := GetColorAtUiPos(9915, 405)
	if (IsColorRange(tRGBColor.r, 255) = true and IsColorRange(tRGBColor.g, 0) = true and IsColorRange(tRGBColor.b, 0) = true and Is22Popup() != true)
	{
		rReturnValue := true
	}

	gIgnoreKeyPress := false
	return rReturnValue
}

;------------------------------------------------------------------------------------------
IsDeleteCharPopup()
{
	gIgnoreKeyPress := true
	rReturnValue := false

	tRGBColorBackdrop := GetColorAtUiPos(450, 331)
	tRGBColorEditbox := GetColorAtUiPos(10057, 400)
	if (IsColorRange(tRGBColorBackdrop.r, 0) = true and IsColorRange(tRGBColorBackdrop.g, 40) = true and IsColorRange(tRGBColorBackdrop.b, 0) = true) and (IsColorRange(tRGBColorEditbox.r, 3) = true and IsColorRange(tRGBColorEditbox.g, 17) = true and IsColorRange(tRGBColorEditbox.b, 3) = true)
	{
		rReturnValue := true
	}

	gIgnoreKeyPress := false
	return rReturnValue
}


;------------------------------------------------------------------------------------------
IsReconnect()
{
	gIgnoreKeyPress := true
	rReturnValue := false

	tRGBColor := GetColorAtUiPos(9917, 441)
	if (IsColorRange(tRGBColor.r, 255) = true and IsColorRange(tRGBColor.g, 0) = true and IsColorRange(tRGBColor.b, 0) = true)
	{
		rReturnValue := true
	}

	gIgnoreKeyPress := false
	return rReturnValue
}

;------------------------------------------------------------------------------------------
IsConnectingToGame()
{
	gIgnoreKeyPress := true
	rReturnValue := false

	tRGBColor := GetColorAtUiPos(570,394)
	if (tRGBColor.r > 100 and tRGBColor.g < 40 and tRGBColor.b < 40)
	{
		rReturnValue := true
	}

	gIgnoreKeyPress := false
	return rReturnValue
}

;------------------------------------------------------------------------------------------
; functions
;------------------------------------------------------------------------------------------
;------------------------------------------------------------------------------------------
ScreenToUiNEW(x, y)
{
	fUIx := 0
	oneThirdSW := A_ScreenWidth / 3

	if(x >= (oneThirdSW * 2)) ;anchor right
	{
		fUIx := (GetUiX() * (((A_ScreenWidth - x) / (A_ScreenWidth / 100)) / 100)) * -1
	}
	else if(x < oneThirdSW * 2 and x > oneThirdSW) ;anchor center
	{
		fUIx := ((GetUiX() / 100) * ((x - (A_ScreenWidth / 2)) / (A_ScreenWidth / 100))) + 10000
	}
	else if(x <= oneThirdSW) ;anchor left
	{
		fUIx := GetUiX() * (x / A_ScreenWidth)
	}

	Array := {X: (fUIx), Y: (768 * (y / A_ScreenHeight))}
	return Array
}

;------------------------------------------------------------------------------------------
UiToScreenNEW(x, y)
{
	fSx := 0

	if(x >= 7000) ;anchor center
	{
		fSx := (((x - 10000) / (GetUiX() / 100)) * (A_ScreenWidth / 100)) + (A_ScreenWidth / 2)
	}
	else if(x <= 0) ;anchor right
	{
		fSx := A_ScreenWidth - ((A_ScreenWidth / 100) * ((x * -1) / (GetUiX() / 100)))
	}
	else if(x < 7000) ;anchor left
	{
		fSx := (x / (GetUiX() / 100)) * (A_ScreenWidth / 100)
	}

	fSy := (A_ScreenHeight * (y / 768))

	if (GetAR() < 1)
	{

		PixelGetColor, color, 2, 2, RGB,
		v1blue := (color & 0xFF)
		v1green := ((color & 0xFF00) >> 8)
		v1red := ((color & 0xFF0000) >> 16)
		if (v1blue < 255 || v1green > 0 || v1red > 0)
		{
			fSy := (y * 1.334) + ((A_ScreenHeight - (768 * 1.334)) / 2)
		}
	}

	Array := {X: (fSx), Y: (fSy)}

	return Array
}

SwitchToMode_1()
{
		mode := -1
		PlayUtterance("paused")
		sleep, 1500
}

;------------------------------------------------------------------------------------------
SwitchToMode0()
{
		mode := 0
		PlayUtterance("switched_to_play_mode")
		sleep, 1500
}

;------------------------------------------------------------------------------------------
SwitchToMode1()
{
		gNumberOfCharsOnCurrentRealm := -1
		mode = 1
		PlayUtterance("switched_to_login_mode")
		sleep, 1500
}

;------------------------------------------------------------------------------------------
GetAR()
{
	ar := A_ScreenWidth / A_ScreenHeight
	return ar
}


;------------------------------------------------------------------------------------------
PlayUtterance(menuName)
{
	soundFiles1 := {US_realms:"00001_sku_en_eu.mp3"
		,USA_West:"00002_sku_en_eu.mp3"
		,Anathema:"00003_sku_en_eu.mp3"
		,Arcanite_Reaper:"00004_sku_en_eu.mp3"
		,Atiesh:"00005_sku_en_eu.mp3"
		,Azursong:"00006_sku_en_eu.mp3"
		,Bigglesworth:"00007_sku_en_eu.mp3"
		,Biaumeux:"00008_sku_en_eu.mp3"
		,Fairbanks:"00009_sku_en_eu.mp3"
		,Grobbulus:"00010_sku_en_eu.mp3"
		,Kurinnaxx:"00011_sku_en_eu.mp3"
		,Myzrael:"00012_sku_en_eu.mp3"
		,Old_Blanchy:"00013_sku_en_eu.mp3"
		,Rattlegore:"00014_sku_en_eu.mp3"
		,Smolderweb:"00015_sku_en_eu.mp3"
		,Thunderfury:"00016_sku_en_eu.mp3"
		,Whitemane:"00017_sku_en_eu.mp3"
		,USA_East:"00018_sku_en_eu.mp3"
		,Ashkandi:"00019_sku_en_eu.mp3"
		,Benediction:"00020_sku_en_eu.mp3"
		,Bloodsail_Buccaneers:"00021_sku_en_eu.mp3"
		,Deviate_Delight:"00022_sku_en_eu.mp3"
		,Earthfury:"00023_sku_en_eu.mp3"
		,Faerlina:"00024_sku_en_eu.mp3"
		,Heartseeker:"00025_sku_en_eu.mp3"
		,Herod:"00026_sku_en_eu.mp3"
		,Incendius:"00027_sku_en_eu.mp3"
		,Kirtonos:"00028_sku_en_eu.mp3"
		,Krmocrush:"00029_sku_en_eu.mp3"
		,Mankrik:"00030_sku_en_eu.mp3"
		,Netherwind:"00031_sku_en_eu.mp3"
		,Pagle:"00032_sku_en_eu.mp3"
		,Skeram:"00033_sku_en_eu.mp3"
		,Stalagg:"00034_sku_en_eu.mp3"
		,Sulfuras:"00035_sku_en_eu.mp3"
		,Thalnos:"00036_sku_en_eu.mp3"
		,Westfall:"00037_sku_en_eu.mp3"
		,Windseeker:"00038_sku_en_eu.mp3"
		,Oceanic:"00039_sku_en_eu.mp3"
		,Argual:"00040_sku_en_eu.mp3"
		,Felstriker:"00041_sku_en_eu.mp3"
		,Remulos:"00042_sku_en_eu.mp3"
		,Yojamba:"00043_sku_en_eu.mp3"
		,Latin_America:"00044_sku_en_eu.mp3"
		,Loatheb:"00045_sku_en_eu.mp3"
		,Brasil:"00046_sku_en_eu.mp3"
		,Sul_thraze:"00047_sku_en_eu.mp3"
		,EU_realms:"00048_sku_en_eu.mp3"
		,english:"00049_sku_en_eu.mp3"
		,Ashbringer:"00050_sku_en_eu.mp3"
		,Bloodfang:"00051_sku_en_eu.mp3"
		,Dragonfang:"00052_sku_en_eu.mp3"
		,Dreadmist:"00053_sku_en_eu.mp3"
		,Earthshaker:"00054_sku_en_eu.mp3"
		,Firemaw:"00055_sku_en_eu.mp3"
		,Flamelash:"00056_sku_en_eu.mp3"
		,Gandling:"00057_sku_en_eu.mp3"
		,Gehennas:"00058_sku_en_eu.mp3"
		,Golemagg:"00059_sku_en_eu.mp3"
		,Hydraxian_Waterlords:"00060_sku_en_eu.mp3"
		,Judgement:"00061_sku_en_eu.mp3"
		,Mirage_Raceway:"00062_sku_en_eu.mp3"
		,Mograine:"00063_sku_en_eu.mp3"
		,Nethergarde_Keep:"00064_sku_en_eu.mp3"
		,Noggenfogger:"00065_sku_en_eu.mp3"
		,Stonespine:"00066_sku_en_eu.mp3"
		,Pyrewood_Village:"00067_sku_en_eu.mp3"
		,Ten_Storms:"00068_sku_en_eu.mp3"
		,Razorgore:"00069_sku_en_eu.mp3"
		,Zandalar_Tribe:"00070_sku_en_eu.mp3"
		,Shazzrah:"00071_sku_en_eu.mp3"
		,Skullflame:"00072_sku_en_eu.mp3"
		,german:"00073_sku_en_eu.mp3"
		,celebras:"00074_sku_en_eu.mp3"
		,dragons_call:"00075_sku_en_eu.mp3"
		,everlook:"00076_sku_en_eu.mp3"
		,heartstriker:"00077_sku_en_eu.mp3"
		,lakeshire:"00078_sku_en_eu.mp3"
		,lucifron:"00079_sku_en_eu.mp3"
		,patchwerk:"00080_sku_en_eu.mp3"
		,razorfen:"00081_sku_en_eu.mp3"
		,transcendence:"00082_sku_en_eu.mp3"
		,venoxis:"00083_sku_en_eu.mp3"
		,french:"00084_sku_en_eu.mp3"
		,Amnennar:"00085_sku_en_eu.mp3"
		,Auberdine:"00086_sku_en_eu.mp3"
		,Finkle:"00087_sku_en_eu.mp3"
		,Sulfuron:"00088_sku_en_eu.mp3"
		,spanish:"00089_sku_en_eu.mp3"
		,Mandokir:"00090_sku_en_eu.mp3"}


	soundFiles := {1:"00001_sku_ahk"
		,2:"00002_sku_ahk"
		,3:"00003_sku_ahk"
		,4:"00004_sku_ahk"
		,5:"00005_sku_ahk"
		,5:"00006_sku_ahk"
		,6:"00007_sku_ahk"
		,7:"00008_sku_ahk"
		,8:"00009_sku_ahk"
		,9:"00010_sku_ahk"
		,10:"00011_sku_ahk"
		,11:"00012_sku_ahk"
		,12:"00013_sku_ahk"
		,13:"00014_sku_ahk"
		,14:"00015_sku_ahk"
		,15:"00016_sku_ahk"
		,16:"00017_sku_ahk"
		,17:"00018_sku_ahk"
		,18:"00019_sku_ahk"
		,19:"00020_sku_ahk"
		,20:"00021_sku_ahk"
		,21:"00022_sku_ahk"
		,22:"00023_sku_ahk"
		,23:"00024_sku_ahk"
		,24:"00025_sku_ahk"
		,25:"00026_sku_ahk"
		,selected:"00027_sku_ahk"
		,fail_restart:"00028_sku_ahk"
		,char_created:"00029_sku_ahk"
		,fail_name:"00030_sku_ahk"
		,creating_wait:"00031_sku_ahk"
		,aborting_creation:"00032_sku_ahk"
		,fail_connection_restart:"00033_sku_ahk"
		,fail_unknown_restart:"00034_sku_ahk"
		,enter_name_press_enter_or_esc:"00035_sku_ahk"
		,max_chars_on_server:"00036_sku_ahk"
		,switching_to_server:"00037_sku_ahk"
		,switched_to_Server:"00038_sku_ahk"
		,character:"00039_sku_ahk"
		,characters:"00040_sku_ahk"
		,on_this_server:"00041_sku_ahk"
		,enter_delete_and_press_enter:"00042_sku_ahk"
		,char_deleted:"00043_sku_ahk"
		,switched_to_play_mode:"00044_sku_ahk"
		,switched_to_login_mode:"00045_sku_ahk"
		,current_mode:"00046_sku_ahk"
		,play_mode:"00047_sku_ahk"
		,login_mode:"00048_sku_ahk"
		,wow_window_not_focus:"00049_sku_ahk"
		,wow_window_not_available:"00050_sku_ahk"
		,unknown_resolution:"00051_sku_ahk"
		,fail:"00052_sku_ahk"
		,char_number:"00053_sku_ahk"
		,main_menu:"00054_sku_ahk"
		,select_char:"00055_sku_ahk"
		,login_with_selected_char:"00056_sku_ahk"
		,login:"00057_sku_ahk"
		,delete_char:"00058_sku_ahk"
		,create_char:"00059_sku_ahk"
		,male:"00060_sku_ahk"
		,female:"00061_sku_ahk"
		,warrior:"00062_sku_ahk"
		,priest:"00063_sku_ahk"
		,hunter:"00064_sku_ahk"
		,shaman:"00065_sku_ahk"
		,mage:"00066_sku_ahk"
		,paladin:"00067_sku_ahk"
		,rogue:"00068_sku_ahk"
		,warlock:"00069_sku_ahk"
		,druid:"00070_sku_ahk"
		,human:"00071_sku_ahk"
		,dwarf:"00072_sku_ahk"
		,gnome:"00073_sku_ahk"
		,nightelf:"00074_sku_ahk"
		,orc:"00075_sku_ahk"
		,troll:"00076_sku_ahk"
		,tauren:"00077_sku_ahk"
		,bloodelf:"00078_sku_ahk"
		,draenei:"00079_sku_ahk"
		,switch_server:"00080_sku_ahk"
		,enter_world:"00081_sku_ahk"
		,language:"00082_sku_ahk"
		,server_type:"00083_sku_ahk"
		,english:"00084_sku_ahk"
		,german:"00085_sku_ahk"
		,french:"00086_sku_ahk"
		,spanish:"00087_sku_ahk"
		,russian:"00088_sku_ahk"
		,ok:"00089_sku_ahk"
		,cancel:"00090_sku_ahk"
		,celebras:"00091_sku_ahk"
		,dragons_call:"00092_sku_ahk"
		,everlook:"00093_sku_ahk"
		,heartstriker:"00094_sku_ahk"
		,lakeshire:"00095_sku_ahk"
		,lucifron:"00096_sku_ahk"
		,patchwerk:"00097_sku_ahk"
		,razorfen:"00098_sku_ahk"
		,transcendence:"00099_sku_ahk"
		,venoxis:"00100_sku_ahk"
		,pvp:"00101_sku_ahk"
		,pve:"00102_sku_ahk"
		,rp_pve:"00103_sku_ahk"
		,rp_pvp:"00104_sku_ahk"
		,enter_name:"00105_sku_ahk"
		,create:"00106_sku_ahk"
		,generate_random_character:"00107_sku_ahk"
		,alliance:"00108_sku_ahk"
		,horde:"00109_sku_ahk"
		,wait:"sound-notification6"
		,undead:"02132105238869"
		,empty:"1906210523-18103"
		,paused:"1906210523-19653"
		,fail_delete_retype_delete_and_press_enter_or_escape:"2306221"
		,aborting_deletion:"2306222"
		,enter_delete_and_press_enter_or_esc_to_cancel:"2306223"
		,script_exited:"2306224"
		,move_character_up:"2306225"
		,move_character_down:"2306226"}


	if(soundFiles[menuName] != "")
	{
		;SoundPlay, % A_WorkingDir . "\soundfiles\" . soundFiles1[menuName]
		SoundPlay, % A_WorkingDir . "\soundfiles\" . soundFiles[menuName] . "_de.mp3"
	}
	else
	{
		SoundPlay, % A_WorkingDir . "\soundfiles\" . soundFiles1[menuName]
	}
}


;------------------------------------------------------------------------------------------
UpdateChilds(menuObj)
{
	Loop % menuObj.childs.MaxIndex()
	{
		if (A_Index = 1)
		{
			menuObj.childs[1].n := menuObj.childs[2]
		}
		else if (A_Index = menuObj.childs.MaxIndex())
		{
			menuObj.childs[A_Index].p := menuObj.childs[A_Index - 1]
		}
		else
		{
			menuObj.childs[A_Index].p := menuObj.childs[A_Index - 1]
			menuObj.childs[A_Index].n := menuObj.childs[A_Index + 1]
		}
	}
}

;------------------------------------------------------------------------------------------
GetUiX()
{
	ar := GetAR()

	if (ar < 1.34)
	{
		return 960
	}
	else if (ar < 1.49)
	{
		return 1024
	}
	else if (ar < 1.59)
	{
		return 1152
	}
	else if (ar < 1.77)
	{
		return 1228.8
	}
	else
	{
		return 1365.33
	}
}

;------------------------------------------------------------------------------------------
GetNumberOfChars()
{
	gIgnoreKeyPress := true
	rReturnValue := 0

	tCharSlots := {1:{x:-45,y:100},2:{x:-45,y:155},3:{x:-45,y:210},4:{x:-45,y:270},5:{x:-45,y:330},6:{x:-45,y:380},7:{x:-45,y:450},8:{x:-45,y:510},9:{x:-45,y:560},10:{x:-45,y:610}}

	loop 9
	{
		gosub CheckMode
		if(Mode != 1)
		{
			break
		}

		tmp := UiToScreenNEW(tCharSlots[A_Index].x,tCharSlots[A_Index].y)
		MouseMove, tmp.X, tmp.Y, 0

		WaitForX(1, 150)
		tRGBColor := GetColorAtUiPos(tCharSlots[A_Index].x,tCharSlots[A_Index].y)
		if (tRGBColor.r > 250 and tRGBColor.g > 250 and tRGBColor.b > 250)
		{
			rReturnValue := rReturnValue + 1
		}
		else
		{
			gIgnoreKeyPress := false
			return rReturnValue
		}
	}

	gIgnoreKeyPress := false
	return rReturnValue
}

;------------------------------------------------------------------------------------------
GetColorAtUiPos(x, y)
{
	rReturnValue := {red:-1,green:-1,blue:-1}

	tmp := UiToScreenNEW(x, y)

	if (tmp.X > 0 and tmp.Y > 0)
	{
		PixelGetColor, color, tmp.X, tmp.Y, RGB,

		v1blue := (color & 0xFF)
		v1green := ((color & 0xFF00) >> 8)
		v1red := ((color & 0xFF0000) >> 16)

		rReturnValue := {r:v1red,g:v1green,b:v1blue}
	}

	return rReturnValue
}

;------------------------------------------------------------------------------------------
gMainMenuchilds1ChildsXGenericAction(this, charNumber) ;unfortunately this ugly helper is required as ahk can't directly assign funcs to variables/objects :(
{
	tmp := UiToScreenNEW(gCharUIPositions[charNumber].x, gCharUIPositions[charNumber].y)
	MouseMove, tmp.X, tmp.Y, 0
	Send {Click}

	PlayUtterance(charNumber)
	sleep 600
	PlayUtterance("selected")
	sleep 1000

	gMainMenu.childs[2].onEnter()
}
UpdateCharacterMenu()
{
	WaitForX(1, 100)

	gNumberOfCharsOnCurrentRealm := GetNumberOfChars()

	tMainItemN := 1

	gMainMenu.childs[tMainItemN].childs := []
	if(gNumberOfCharsOnCurrentRealm = 0)
	{
		gMainMenu.childs[tMainItemN].childs[1] := new baseMenuEntryObject
		gMainMenu.childs[tMainItemN].childs[1].parent := gMainMenu.childs[tMainItemN]
		gMainMenu.childs[tMainItemN].childs[1].name := "empty"
	}
	else
	{
		Loop, 9
		{
			if(Mode != 1)
			{
				break
				return
			}
			if(A_Index <= gNumberOfCharsOnCurrentRealm)
			{
				gMainMenu.childs[tMainItemN].childs[A_Index] := new baseMenuEntryObject
				gMainMenu.childs[tMainItemN].childs[A_Index].parent := gMainMenu.childs[tMainItemN]
				gMainMenu.childs[tMainItemN].childs[A_Index].name := A_Index
				gMainMenu.childs[tMainItemN].childs[A_Index].onAction := Func("gMainMenuchilds1ChildsXGenericAction").Bind(gMainMenu.childs[tMainItemN].childs[A_Index], A_Index)
			}
		}
	}

	UpdateChilds(gMainMenu.childs[tMainItemN])
}

;------------------------------------------------------------------------------------------
WaitForX(waitCycles, ms)
{
	gIgnoreKeyPress = true
	loop % waitCycles
	{
		gosub CheckMode
		if (mode != 1)
		{
			break
			return
		}

		PlayUtterance("wait")
		sleep ms
	}
	gIgnoreKeyPress = false
}

;------------------------------------------------------------------------------------------
EnterCharacterNameHandler()
{
	gIgnoreKeyPress := true
	WaitForX(6, 500)

	tFoundSuccessOrFail := false

	while tFoundSuccessOrFail != true
	{
		if(mode != 1)
		{
			return
		}

		if(A_Index > 40)
		{
			gEnterCharacterNameFlag := false
			gIgnoreKeyPress := false
			PlayUtterance("fail_connection_restart")
			sleep 2000
			gIgnoreKeyPress := false
			SwitchToMode_1()
			Pause
			return
		}
		WaitForX(1, 500)

		if(IsCharSelectionScreen() = true)
		{
			;char created, we're back to char selection screen
			gEnterCharacterNameFlag := false
			PlayUtterance("char_created")
			sleep 1000
			PlayUtterance("selected")
			sleep 600

			tFoundSuccessOrFail := true
			WaitForX(4, 500)

			UpdateCharacterMenu()
			gMainMenu.childs[2].onEnter()

			gIgnoreKeyPress := false
			return
		}
		else
		{
			if(gEnterCharacterNameFlag != false)
			{
				tNoSuccessButtonCheck := false
				tNoSuccessBackdropCheck := false

				If(IsCharCreationScreen() = true and (Is11Popup() = true or Is21Popup() = true))
				{
					tNoSuccessButtonCheck := true
				}

				if((tNoSuccessButtonCheck = true) and IsCharSelectionScreen() = false)
				{
					;char name not available or no char name > retry
					tFoundSuccessOrFail := true

					Send {Enter}
					WaitForX(1, 300)
					send ^a
					WaitForX(1, 100)
					send ^{Backspace}
					WaitForX(1, 100)

					PlayUtterance("fail_name")
				}
			}
		}
	}
	gIgnoreKeyPress := false
}
;------------------------------------------------------------------------------------------
DeleteCharacterNameHandler()
{
	gIgnoreKeyPress := true
	WaitForX(6, 500)

	tFoundSuccessOrFail := false

	while tFoundSuccessOrFail != true
	{
		if(mode != 1)
		{
			return
		}

		if(A_Index > 40)
		{
			gDeleteCharacterNameFlag := false
			gIgnoreKeyPress := false
			PlayUtterance("fail_connection_restart")
			sleep 2000
			gIgnoreKeyPress := false
			SwitchToMode_1()
			Pause
			return
		}
		WaitForX(1, 500)

		if(gDeleteCharacterNameFlag = true)
		{
			if(IsDeleteButtonDisabled() = true)
			{
				WaitForX(1, 300)
				send ^a
				WaitForX(1, 100)
				send ^{Backspace}
				WaitForX(1, 100)

				PlayUtterance("fail_delete_retype_delete_and_press_enter_or_escape")
				sleep 3000
				tFoundSuccessOrFail := true

			}
			else if(IsDeleteButtonEnabled() = true)
			{
				gDeleteCharacterNameFlag := false
				tmpScreen := UiToScreenNEW(9796, 437)
				MouseMove, floor(tmpScreen.X), floor(tmpScreen.Y), 0
				PlayUtterance("char_deleted")
				Send {Click}
				sleep 1500

				tFoundSuccessOrFail := true
				WaitForX(4, 500)

				UpdateCharacterMenu()
				gMainMenu.childs[1].onEnter()

				gIgnoreKeyPress := false
				return
			}
			else
			{
				tFoundSuccessOrFail := true
				WaitForX(4, 500)

				UpdateCharacterMenu()
				gMainMenu.childs[1].onEnter()

				gIgnoreKeyPress := false
				return
			}
		}
		else
		{
			tFoundSuccessOrFail := true
			WaitForX(4, 500)

			UpdateCharacterMenu()
			gMainMenu.childs[1].onEnter()

			gIgnoreKeyPress := false
			return
		}
	}
	gIgnoreKeyPress := false
}
;------------------------------------------------------------------------------------------
; Select modus Keybinds
;------------------------------------------------------------------------------------------
#If mode = 1
	;------------------------------------------------------------------------------------------
	Right::
		if(mode != 1)
		{
			send {Right}
			return
		}

		if (gIgnoreKeyPress = true)
		{
			;return
		}

		if (gCurrentMenuItem not)
		{
			return
		}
		if (gCurrentMenuItem.childs[1] not)
		{
			gCurrentMenuItem.onEnter()
			return
		}
		gCurrentMenuItem.onSelect()
	return

	;------------------------------------------------------------------------------------------
	Left::
		if(mode != 1)
		{
			send {Left}
			return
		}

		if (gIgnoreKeyPress = true)
		{
			;return
		}

		if (gCurrentMenuItem not)
		{
			return
		}
		if (gCurrentMenuItem.parent not)
		{
			gCurrentMenuItem.onEnter()
			return
		}

		gCurrentMenuItem.parent.onEnter()
	return

	;------------------------------------------------------------------------------------------
	Up::
		gosub CheckMode
		if(mode != 1)
		{
			send {Up}
			return
		}

		if (gIgnoreKeyPress = true)
		{
			;return
		}

		if (gCurrentMenuItem not)
		{
			return
		}
		if (gCurrentMenuItem.p not)
		{
			gCurrentMenuItem.onEnter()
			return
		}
		gCurrentMenuItem.p.onEnter()
	return

	;------------------------------------------------------------------------------------------
	Down::
		gosub CheckMode
		if(mode != 1)
		{
			send {Down}
			return
		}

		if (gIgnoreKeyPress = true)
		{
			;return
		}

		if (gCurrentMenuItem not)
		{
			return
		}
		if (gCurrentMenuItem.n not)
		{
			gCurrentMenuItem.onEnter()
			return
		}
		gCurrentMenuItem.n.onEnter()
	return

	;------------------------------------------------------------------------------------------
	Enter::
		gosub CheckMode
		if(mode != 1)
		{
			send {Enter}
			return
		}

		if (gIgnoreKeyPress = true)
		{
			;return
		}

		if(gEnterCharacterNameFlag = true)
		{
			PlayUtterance("creating_wait")

			send {Enter}
			EnterCharacterNameHandler()
		}
		else if(gDeleteCharacterNameFlag = true)
		{
			;send {Enter}
			DeleteCharacterNameHandler()
		}
		else
		{
			if (gCurrentMenuItem not)
			{
				return
			}
			gCurrentMenuItem.onAction()
		}
	return

	;------------------------------------------------------------------------------------------
	Escape::
		gosub CheckMode
		if(mode != 1)
		{
			send {Esc}
			return
		}

		if (gIgnoreKeyPress = true)
		{
			;return
		}

		if(gEnterCharacterNameFlag = true)
		{
			gEnterCharacterNameFlag := false

			PlayUtterance("aborting_creation")
			sleep 1500

			tmp := UiToScreenNEW(-72, 733)
			MouseMove, tmp.X, tmp.Y, 0
			Send {Click}

			tTimeout := 0
			while(IsCharSelectionScreen() != true)
			{
				gosub CheckMode
				if(Mode != 1)
				{
					return
				}

				tTimeout := tTimeout + 1
				WaitForX(1, 500)
				if(tTimeout > 60)
				{
					PlayUtterance("fail_connection_restart")
					sleep 2000
					gIgnoreKeyPress := false
					SwitchToMode_1()
					Pause
				return
				}
			}

			gMainMenu.childs[3].onEnter()
		}

		if(gDeleteCharacterNameFlag = true)
		{
			gDeleteCharacterNameFlag := false

			PlayUtterance("aborting_deletion")

			sleep 1000

			if (IsDeleteCancelButton() = true)
			{
				tmp := UiToScreenNEW(10195, 437)
				MouseMove, tmp.X, tmp.Y, 0
				Send {Click}
			}

			tTimeout := 0
			while(IsCharSelectionScreen() != true)
			{
				gosub CheckMode
				if(Mode != 1)
				{
					return
				}

				tTimeout := tTimeout + 1
				WaitForX(1, 500)
				if(tTimeout > 60)
				{
					PlayUtterance("fail_connection_restart")
					sleep 2000
					gIgnoreKeyPress := false
					SwitchToMode_1()
					Pause
				return
				}
			}

			gMainMenu.childs[1].onEnter()
		}
	return
#If

;------------------------------------------------------------------------------------------
; Play modus keybinds; set view 2-5 and mouse position to view 2-5; we don't use view 1 (first person) and 3
;------------------------------------------------------------------------------------
#If mode = 0
	;------------------------------------------------------------------------------------------
	;view 2
	Numpad7::
		gosub CheckMode
		if(mode = 0)
		{
			WinGetPos, X, Y, Width, Height, Program Manager
			Width := Width / 2
			Height := Height / 2 + (Height / 3.5)
			CoordMode, Mouse, Screen
			MouseMove, %Width%, %Height%
			Send ^{Numpad7}
			Sleep, 500
			SendEvent {Click, right}
		}
	return

	;------------------------------------------------------------------------------------------
	;view 4
	Numpad8::
		gosub CheckMode
		if(mode = 0)
		{
			WinGetPos, X, Y, Width, Height, Program Manager
			Width := Width / 2
			Height := Height / 2 + (Height / 9.5)
			CoordMode, Mouse, Screen
			MouseMove, %Width%, %Height%
			Send ^{Numpad8}
			Sleep, 500
			SendEvent {Click, right}
		}
	return

	;------------------------------------------------------------------------------------------
	;view 5
	Numpad9::
	i::
		Send i
		gosub CheckMode
		if(mode = 0)
		{
			tmpUI := ScreenToUiNEW(1, 20)
			tRGBColor := GetColorAtUiPos(tmpUI.x, tmpUI.y)
			if (IsColorRange(tRGBColor.r, 255) = true and IsColorRange(tRGBColor.g, 0) = true and IsColorRange(tRGBColor.b, 0) = true)
			{
				WinGetPos, X, Y, Width, Height, Program Manager
				Width := Width / 2
				Height := 5
				CoordMode, Mouse, Screen
				MouseMove, %Width%, %Height%
				Sleep, 250
				SendEvent {Click, right}
				Sleep, 1
				MouseMove, %Width%, %Height%
			}
		}
	return
#If
