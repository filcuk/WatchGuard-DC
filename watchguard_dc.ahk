#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
#SingleInstance, Force
#Persistent

FileCreateDir, res
FileInstall, res/wg_main.ico, res/wg_main.ico, 1
FileInstall, res/wg_issue.ico, res/wg_issue.ico, 1
FileInstall, res/wg_postpone.ico, res/wg_postpone.ico, 1
FileInstall, res/wg_suspended.ico, res/wg_suspended.ico, 1

gAppPath:= "C:\Program Files (x86)\Desktop Connect\"
gAppExe:= "DesktopConnect.exe"
gAppExePath:= gAppPath . gAppExe
gProcCheckDelay:=1
gNotify:=true
gIcoMain:="res/wg_main.ico"
gIcoIssue:="res/wg_issue.ico"
gIcoPostpone:="res/wg_postpone.ico"
gIcoSuspended:="res/wg_suspended.ico"

Menu, Tray, Icon, % gIcoMain,, 1
Menu, Tray, NoStandard
Menu, Tray, Tip, WatchGuard for Desktop Connect

Menu, Tray, Add, WatchGuard for Desktop Connect, AppInfo
Menu, Tray, Icon, WatchGuard for Desktop Connect, % gIcoMain
Menu, Tray, Add
Menu, Tray, Add, Launch Desktop Connect, AppRun
;Menu, Tray, Add, &Suspend, AppSuspend
Menu, Tray, Add, &Reload, AppReload
Menu, Tray, Add, &Exit, AppExit

Sleep, gProcCheckDelay*1000

Loop {
	Process, Exist, %gAppExe%
	
	if (ErrorLevel) {
		if (A_IsSuspended)
			Menu, Tray, Icon, % gIcoSuspended,, 1
		else
			Menu, Tray, Icon, % gIcoMain,, 1
		
		gNotify:=true
	} else {
		if (gNotify) {
			Menu, Tray, Icon, % gIcoIssue,, 1
			MsgBox, 8241, WatchGuard, Desktop Connect isn't running.`n`nDo you want to launch new instance?
			
			IfMsgBox, OK
			{
				Run, %gAppExe%, %gAppPath%, Hide
				Process, Wait, %gAppExe%, 10000
			} else {
				gNotify:=false
				Menu, Tray, Icon, % gIcoPostpone,, 1
			}
		}
	}
	
	Sleep, gProcCheckDelay*1000
}

AppRun:
Run, %gAppExe%, %gAppPath%, Hide
return

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
	MsgBox, 8192, WatchGuard, WatchGuard for Desktop Connect`n`nFilip Kraus, 2019`nfilip.kraus@corporatesolutions.uk.net
return