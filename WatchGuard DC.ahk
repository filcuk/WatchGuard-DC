;~ Initial ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
;~ #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
#SingleInstance, Force
#Persistent


;~ Globals ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

EnvGet, LocalAppData, LOCALAPPDATA

WG_Ver := "0.3"
WG_Title := "WatchGuard DC"
WG_Exe := "WatchGuard DC.exe"
WG_Dir := LocalAppData . "\WatchGuard DC"

WG_IcoMain := WG_Dir . "\res\wg_main.ico"
WG_IcoIssue := WG_Dir . "\res\wg_issue.ico"
WG_IcoPostponed := WG_Dir . "\res\wg_postponed.ico"

DC_Dir := "C:\Program Files (x86)\Desktop Connect\"
DC_Exe := "DesktopConnect.exe"
DC_CfgDir := LocalAppData . "\Desktop Connect\"
DC_LogDir := DC_CfgDir . "logs\"
DC_Cfg := DC_CfgDir . "data.json"

DC_IcoMain := WG_Dir . "\res\dc_main.ico"
DC_IcoOffline := WG_Dir . "\res\dc_offline.ico"

CheckDelaySec := 1
Notify:=true


;~ Tray ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Menu, Tray, Icon, % WG_IcoMain,, 1
Menu, Tray, NoStandard
Menu, Tray, UseErrorLevel
Menu, Tray, Tip, WatchGuard for Desktop Connect

Menu, Tray, Add, Launch Desktop Connect, AppRun
Menu, Tray, Icon, Launch Desktop Connect, % DC_IcoMain
Menu, Tray, Add, Restart Session, AppReset
Menu, Tray, Icon, Restart Session, % DC_IcoOffline
Menu, Tray, Add, Show Logs, ShowLogs
Menu, Tray, Add
Menu, Tray, Add, WatchGuard v%WG_Ver%, AppInfo
Menu, Tray, Icon, WatchGuard v%WG_Ver%, % WG_IcoMain
Menu, Tray, Add, Auto-Start, AutoStart
IfExist %A_Startup%\%WG_Title%.lnk, Menu, Tray, Check, Auto-Start
Menu, Tray, Add, &Reload, AppReload
Menu, Tray, Add, &Exit, AppExit


;~ Runtime ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Sleep, CheckDelaySec*1000

Loop {
	Process, Exist, %DC_Exe%
	
	if (ErrorLevel) {
		if (A_IsSuspended)
			Menu, Tray, Icon, % gIcoSuspended,, 1
		else
			Menu, Tray, Icon, % WG_IcoMain,, 1
		
		Notify:=true
	} else {
		if (Notify) {
			Menu, Tray, Icon, % WG_IcoIssue,, 1
			MsgBox, 8241, %WG_Title%, Desktop Connect isn't running.`n`nDo you want to launch new instance?
			
			IfMsgBox, OK
			{
				Run, %DC_Exe%, %DC_Dir%, Hide
				Process, Wait, %DC_Exe%, 10000
			} else {
				Notify:=false
				Menu, Tray, Icon, % WG_IcoPostponed,, 1
			}
		}
	}
	
	Sleep, CheckDelaySec*1000
}

return


;~ Internal ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

AppSuspend:
	Suspend, Toggle
	
	if (A_IsSuspended) {
		Menu, Tray, Icon, % gIcoSuspended,, 1
		Menu, Tray, Check, &Suspend
	} else {
		Menu, Tray, UnCheck, &Suspend
	}
return

AppReload:
	Reload
return

AppExit:
	ExitApp
return

AppInfo:
	MsgBox, 8192, %WG_Title%, WatchGuard for Desktop Connect`nv%WG_Ver%`n`nFilip Kraus, 2019`nfilip.kraus@corporatesolutions.uk.net
return


;~ External ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

ShowLogs:
	Run, %DC_LogDir%
return

AutoStart:
	IfExist %A_Startup%\%A_ScriptName%.lnk
	{
		FileDelete %A_Startup%\%WG_Title%.lnk
		Menu, Tray, UnCheck, Auto-Start
	} else {
		FileCreateShortcut, %A_ScriptFullPath%, %A_Startup%\%WG_Title%.lnk
		Menu, Tray, Check, Auto-Start
	}
return

AppRun:
	Run, %DC_Exe%, %DC_Dir%, Hide
return

AppReset:
	; Kill process, if running
	Process, Close, %DC_Exe%
	Process, WaitClose, %DC_Exe%, 5
	
	Process, Exist, %DC_Exe%
	If (ErrorLevel<>0) {
		MsgBox, 262160, %WG_Title%, Unable to stop process.`n`nClose Desktop Connect and try again.
		return
	}
	
	; Move session file
	if (FileExist(DC_Cfg)) {
		NewFile:= %AppCfgPath% . "data " . %A_Now% . ".json"
		FileMove, %DC_Cfg%, %NewFile%
		MsgBox, 262208, %WG_Title%, Session reset.`n`nYou'll need to sign in again.
		gosub, AppRun
	} else {
		MsgBox, 262192, %WG_Title%, Session file not found.
	}
return