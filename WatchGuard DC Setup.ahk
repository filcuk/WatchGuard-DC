;~ Initial ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
;~ #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
#SingleInstance, Force


;~ Globals ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

EnvGet, LocalAppData, LOCALAPPDATA

WG_Ver := "0.3"
WG_Title := "WatchGuard DC"
WG_Exe := "WatchGuard DC.exe"
WG_Dir := LocalAppData . "\WatchGuard DC"

WG_IcoMain := WG_Dir . "\res\wg_main.ico"
WG_IcoIssue := WG_Dir . "\res\wg_issue.ico"
WG_IcoPostponed := WG_Dir . "\res\wg_postponed.ico"
DC_IcoMain := WG_Dir . "\res\dc_main.ico"
DC_IcoOffline := WG_Dir . "\res\dc_offline.ico"


;~ Resources ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

try {
	Process, Close, %WG_Exe%
	Process, WaitClose, %WG_Exe%, 5
} catch e {
	MsgBox, 262192, %WG_Title%, Please exit previous version first.
	ExitApp
}

try {
	FileCreateDir, %WG_Dir%
	FileCreateDir, %WG_Dir%\res
	FileCreateDir, %WG_Dir%\data
	FileCreateDir, %WG_Dir%\logs

	FileInstall, WatchGuard DC.exe, %WG_Dir%\%WG_Exe%, 1
	FileInstall, res\dc_main.ico, %DC_IcoMain%, 1
	FileInstall, res\dc_offline.ico, %DC_IcoOffline%, 1
	FileInstall, res\wg_main.ico, %WG_IcoMain%, 1
	FileInstall, res\wg_issue.ico, %WG_IcoIssue%, 1
	FileInstall, res\wg_postponed.ico, %WG_IcoPostponed%, 1
} catch e {
	MsgBox, 262192, %WG_Title%, Setup failed.
	ExitApp
}

try {
	FileCreateShortcut, %WG_Dir%\%WG_Exe%, %A_StartMenu%\Programs\%WG_Title%.lnk
	FileCreateShortcut, %WG_Dir%\%WG_Exe%, %A_Startup%\%WG_Title%.lnk
} catch e {
	MsgBox, 262192, %WG_Title%, Cannot create Start Menu shortcuts.
}

MsgBox, 262208, %WG_Title%, Setup complete.


;~ Tray ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Menu, Tray, NoStandard
Menu, Tray, UseErrorLevel


;~ Runtime ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

ExitApp