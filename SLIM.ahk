; Script Library Install Manager

; Script Directives and Initialization

	#NoEnv ; Assume variables are not environment variables
	#SingleInstance Off ; Allow multiple concurrent instances
	FileEncoding UTF-8 ; Assume text files are UTF-8 encoded

; Command line switches
	commands := {-quit:[0,cmd_the_end],-get:[2,cmd_download]}

	If ( argc := %FALSE% )
		GoSub cmd_handler

; Build the GUIs
	Gui 1:Default
	Gui +LastFound +Resize +Labelmain_gui_ +HWNDmain_gui_hwnd
	Gui Font, S15, Verdana
	Gui Font,, Lucida Sans Unicode
	Gui Margin, 3, 3

	Gui Add, Tab2, xm ym -Wrap vgm_tab
	Gui Tab
	Gui Font, S11
	Gui Add, Listview, xm AltSubmit Grid Check +E0x2 vgm_pkglv_hwnd hwndpkglv_hwnd
		, Title|Version|Author|Status|Checked|Manifest Date
	Gui Add, Text, 0x11 w2 vgm_v1
	Gui Add, Text, Center 0x200 vgm_ttitle
	Gui Add, Text, Center 0x200 vgm_tauthor
	Gui Font, S9
	Gui Add, Text, Center Hidden vgm_tmultiauthor
	Gui Add, Edit, r2 vgm_tdesc
	Gui Add, GroupBox,, Requirements
	Gui Font, S11
	Gui Add, Listview, -HDR r5, Title|Author|Status

cmd_handler:
; Handle command line input

	load := []
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
				load.insert(A_LoopFileFullPath)
Return

cmd_download:
	URLDownloadToFile, % argv[argn+1], % argv[argn+2]
Return

cmd_the_end:
	Exitapp
Return


