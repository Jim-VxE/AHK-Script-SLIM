; Script Library Install Manager

; Script Directives and Initialization
settimer cmd_the_end, -9000

	#NoEnv ; Assume variables are not environment variables
	#SingleInstance Off ; Allow multiple concurrent instances
	FileEncoding UTF-8 ; Assume text files are UTF-8 encoded
	gm_buttoncount = 12
	gm_baction_vis := 4
	version = 0.00.01
	slim_reg = SOFTWARE\AHK Scripts\VxE\SLIM
	Global packages := []
	Global slim_man := {"Name":"AHK-Script-Slim","Version":"0.0.0.0"}

;+>	If !InStr( FileExist( A_ScriptDir "\SLIM Data"), "D" )
;+>		FileCreateDir %A_ScriptDir%\SLIM Data

; Load all stored manifests
	SetWorkingDir %A_ScriptDir%\SLIM Data
	Loop *.slim, 0, 0
		load_manifest( A_LoopFileName )

; Download script manifest
	If ( slim_man.Version = "0.0.0.0" )
	{
		0++
		%0% = -get
		0++
		%0% = https://raw.github.com/Jim-VxE/AHK-Script-SLIM/master/slim.slim
		0++
		%0% = %A_ScriptDir%\SLIM Data\slim.slim
	}

; Command line switches
	commands := {"-quit":[0,"cmd_the_end"],"-get":[2,"cmd_download"]}

	If ( argc := %FALSE% )
		GoSub cmd_handler

; Load the configuration files for SLIM
	If ( slim_man.Version = "0.0.0.0" )
	{
		MsgBox, 16, SLIM - Fatal Error, SLIM's configuration file is missing or corrupt.
		Exitapp
	}

; Build the gui menus and tabs
	gm_domain := "AutoHotkey" ; future use - segregate packages by domain

	gm_tab := "`n"
	for k, v in packages
		If !InStr( gm_tab, "`n" v.Category "`n" )
			gm_tab .= v.Category "`n"
	gm_tab := SubStr( gm_tab, 2, -1 )
	Sort gm_tab

; Build the GUIs

	Gui 1:Default ; main gui
	Gui +LastFound +Resize +Disabled +OwnDialogs +Labelmain_gui_ +HWNDmain_gui_hwnd +Delimiter`n
	Gui Font, S15, Verdana
	Gui Font,, Lucida Sans Unicode
	Gui Margin, % gm_mh := 3, % gm_mv := 3

	Gui Add, Tab2, xm ym -Wrap vgm_tab, % gm_tab
	Gui Tab
	Gui Font, S11
	Gui Add, Text, xm 0x200 vgm_tfilter, Filter:
	ControlGetPos,,, gs_tfilterw,, Static1
	Gui Add, Edit, vgm_efilter
	ControlGetPos,,,, gm_lineh, Edit1
	GuiControl MoveDraw, gm_tfilter, H%gm_lineh%
	Gui Add, Listview, xm r4 Hidden vgm_lvpkg, ID|Title|Author|Check
	Gui Add, Listview, xm r5 AltSubmit Grid Checked +E0x2 vgm_lvpkgfilter hwndgm_lvpkgfilter_hwnd
		, Title|Version|Author|Status|Checked|Manifest Date
	Gui Add, Text, 0x11 w2 vgm_v1
	Gui Font, Bold
	Gui Add, Text, h%gm_lineh% Center 0x200 vgm_ttitle, Title
	Gui Font, Norm Italic
	Gui Add, Text, Center 0x200 vgm_tauthor, Author
	Gui Font, S9
	Gui Add, Text, r2 Center Hidden vgm_tmultiauthor, Author 1`, Author 2`, et al...
	Gui Font, Norm
	Gui Add, Text, h%gm_lineh% Center 0x200 vgm_tversion, Version: 1.00
	Gui Add, Edit, r2 -wrap vgm_tdesc, Sample Description
	Gui Add, GroupBox, vgm_breqbox, Requirements
	Gui Font, S11
	Gui Add, Listview, -HDR r5 Grid vgm_lvreqs, Title|Author|Status ; not localized since they're hidden
	Gui Add, Checkbox, h%gm_lineh% vgm_breqign center, Ignore Requirements
	Gui Add, Text, 0x10 h2 vgm_h1
	Gui Font, S15 Bold
	Loop %gm_buttoncount%
		Gui Add, Button, Hidden vgm_ba%A_Index%, %A_Index%
	Gui Font, Norm S11
	Gui Add, StatusBar
	SB_SetParts()

	LV_ModifyCol( 3, "0" )
	VarSetCapacity( rect, 16, 0 )
	SendMessage, 0x130A, 0, &rect, SysTabControl321
	gm_tabh := NumGet( rect, 12, "Int" ) - NumGet( rect, 4, "Int" )
	ControlGetPos,,,, gm_elineh, Edit2
	gm_elineh -= gm_eh
	ControlGetPos,,,, gm_lvrowh, SysListview322
	ControlGetPos,,,, gm_lvhdrh, SysListview321
	gm_lvrowh -= gm_lvhdrh
	ControlGetPos,,,, gm_lvh, SysListview323
	gm_lvhdrh -= gm_lvh
	gm_lvh -= 5 * gm_lvrowh
	ControlGetPos,,,, gm_tauh, Static5
	ControlGetPos,,,, gm_bactionh, Button4
	ControlGetPos,,,, gm_sbh, msctls_statusbar321
	SysGet, vscrollw, 2

	Gui Show, HIDE, SLIM
	Loop 3
		Sleep % 2 - A_Index
	RegRead, gm_win_0, HKLM, % slim_reg, windowPos
	gm_win_0 := ErrorLevel ? "Center,Center,691,427,0" : gm_win_0
	StringSplit, gm_win_, gm_win_0, `,
	WinMove,,,,, gm_win_3, gm_win_4
	Gui, Show, % !gm_win_5 ? "X" gm_win_1 " Y" gm_win_2 : "MAXIMIZE"

	RegRead, lang_pref, HKLM, % slim_reg, languagePreference
	for k, v in slim_man

	Tooltip % 

settimer cmd_the_end, off

	Gui -Disabled
	s =
Return

main_gui_size:
	Gui +LastFound
	main_gui_size( gm_w := A_GuiWidth, -gm_sbh + gm_h := A_GuiHeight )
Return

main_gui_size( W, H ) {
	Local xmid := Round( w * ( sqrt(1.25) - 0.5 ) )
	, bros := ( gm_baction_vis + 5 ) // 6
	, ylow := H - gm_mh - (( gm_baction_vis + 5 ) // 6) * ( gm_mh + gm_bactionh )
	, yhi := gm_tabh + gm_mh + gm_mh
	, yreq, rreq, hreq

	rreq := Round( ( ylow - yhi - 4 * gm_lineh - gm_tauh - 6 * gm_mv ) / ( sqrt(5) * gm_lvrowh ) )
	hreq := rreq * gm_lvrowh + gm_lvh
	yreq := ylow - hreq - 2 - gm_lineh - 4 * gm_mv

	GuiControl MoveDraw, gm_v1, % "X" xmid - 1 " Y" yhi " H" ylow - yhi
	GuiControl MoveDraw, gm_h1, % "W" w - 5 " Y" ylow - 1

	GuiControl MoveDraw, gm_tab, % "W" W - gm_mh - gm_mh " H" gm_tabh + 2
	GuiControl MoveDraw, gm_tfilter, % "Y" yhi + 2
	GuiControl MoveDraw, gm_efilter, % "X" gs_tfilterw + gm_mh + gm_mh " Y" yhi + 2 " W" xmid - 1 - gs_tfilterw - 3 * gm_mh
	GuiControl MoveDraw, gm_lvpkgfilter, % "Y" yhi + 2 + gm_mh + gm_eh " W" xmid - 1 - gm_mh - gm_mh " H" ylow - yhi - 3 * gm_mh - gm_eh

	GuiControl MoveDraw, gm_ttitle, % "X" xmid + 1 + gm_mh " Y" yhi + 2 " W" W - 1 - xmid - 2 * gm_mh
	GuiControl MoveDraw, gm_tauthor, % "X" xmid + 1 + gm_mh " Y" yhi + 2 + gm_mv + gm_lineh " W" W - 1 - xmid - 2 * gm_mh " H" gm_tauh
	GuiControl MoveDraw, gm_tmultiauthor, % "X" xmid + 1 + gm_mh " Y" yhi + 2 + gm_mv + gm_lineh " W" W - 1 - xmid - 2 * gm_mh
	GuiControl MoveDraw, gm_tversion, % "X" xmid + 1 + gm_mh " Y" yhi + 2 + 2 * ( gm_mv + gm_lineh ) " W" W - 1 - xmid - 2 * gm_mh

	GuiControl MoveDraw, gm_tdesc, % "X" xmid + 1 + gm_mh " Y" yhi + 2 + 3 * ( gm_mv + gm_lineh ) " W" W - 1 - xmid - 2 * gm_mh " H" yreq - ( yhi + 2 + 4 * gm_mv + 4 * gm_lineh )

	GuiControl MoveDraw, gm_breqbox, % "X" xmid + 1 + gm_mh " Y" yreq - gm_lineh " W" W - 1 - xmid - 2 * gm_mh " H" hreq + 2 * ( gm_lineh + gm_mv )
	GuiControl MoveDraw, gm_lvreqs, % "X" xmid + 3 + gm_mh + gm_mh " Y" yreq " W" W - 5 - xmid - 4 * gm_mh " H" hreq
	GuiControl MoveDraw, gm_breqign, % "X" xmid + 3 + 3 * gm_mh " Y" yreq + gm_mv + hreq " W" W - 5 - xmid - 6 * gm_mh

	Loop % gm_buttoncount
		If ( gm_baction_vis < A_Index )
			GuiControl Hide, gm_ba%A_Index%
		Else
		{
			GuiControl MoveDraw, gm_ba%A_Index%, % q := btn_pos( A_Index, gm_baction_vis, 6, W, gm_mh, H, gm_mv + gm_bactionh )
			GuiControl Show, gm_ba%A_Index%
		}
}

btn_pos( I, N, K, W, Mh, H, Dy ) {
	rs := 0
	lb := N / ( rc := ( 1 + N // ( K + 1 ) ) )
	while rs < I
		rs += ( lr := Round( ( rn := A_Index ) * lb - rs ) )
	by := H - Dy * ( rc + 1 - rn )
	bw := ( W - Mh - Mh ) / lr
	bx := ( I - 1 - rs + lr ) * bw
	Return "X" Mh + Round( bx ) " Y" by " W" Round( bx + bw ) - Round( bx ) - Mh 
}


cmd_handler:
; Handle command line input

	argv := []
	Loop %argc%
		argv.insert(%A_Index%)
	argn := 0
	while argn++ < argc
		If commands.HasKey(argv[argn])
		{
			GoSub % commands[argv[argn]][2]
			argn += commands[argv[argn]][1]
		}
		Else If InStr( argv[argn] "`n", ".slim`n" )
			Loop % argv[argn], 0, 0
				load_manifest(A_LoopFileFullPath)
Return

cmd_download:
	URLDownloadToFile, % argv[argn+1], % argv[argn+2]
Return

main_gui_escape:
main_gui_close:
	Gui 1:+LastFound
	WinGet, gm_win_5, MINMAX
	If !gm_win_5
		WinGetPos, gm_win_1, gm_win_2, gm_win_3, gm_win_4
;+>	RegWrite, REG_SZ, HKLM, % slim_reg, windowPos, %gm_win_1%`,%gm_win_2%`,%gm_win_3%`,%gm_win_4%`,%gm_win_5%

cmd_the_end:
	Exitapp
Return

load_manifest( fpath ) {
	FileRead s, %fpath%

	If IsObject( s := json_toobj( s ) ) && v.HasKey( "MANIFEST" )
		for i, v in s.MANIFEST.PACKAGES
		{
			packages.Insert( v )
			If ( slim_man.Name = v.Name ) && 0 < cmp_ver( slim_man.Version, v.Version )
				slim_man := v
		}
}

#include incl.ahk
