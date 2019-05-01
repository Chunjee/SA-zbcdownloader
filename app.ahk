;/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\
;Description
;\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/
; Adds user-configurable file renaming options to the windows explorer right-click menu
; 
The_ProjectName := "zbcdownloader"
The_VersionNumb = 0.1.0

;~~~~~~~~~~~~~~~~~~~~~
;Compile Options
;~~~~~~~~~~~~~~~~~~~~~
SetBatchLines -1 ;Go as fast as CPU will allow
#SingleInstance force
#Persistent

;Dependencies
#Include %A_ScriptDir%\lib
#Include util-misc.ahk\export.ahk

;For Debug Only
; #Include %A_ScriptDir%\lib\unit-testing.ahk\export.ahk 

;Classes
#Include log.ahk\export.ahk
#Include json.ahk\export.ahk
; #Include %A_ScriptDir%\lib\json.ahk\export.ahk

;Modules
; #Include %A_ScriptDir%
; #Include GUI.ahk


Sb_InstallFiles() ;Install included files and make any directories required

;/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\
; StartUp
;\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/

;; Creat Logging obj
log := new Log_class(The_ProjectName "-" A_YYYY A_MM A_DD, A_ScriptDir "\logfiles")
log.maxSizeMBLogFile_Default := 99 ;Set log Max size to 99 MB
log.application := The_ProjectName
log.preEntryString := "%A_NowUTC% -- "
; log.postEntryString := "`r"
log.initalizeNewLogFile(false, The_ProjectName " v" The_VersionNumb " log begins...`n")
log.add(The_ProjectName " launched from user " A_UserName " on the machine " A_ComputerName ". Version: v" The_VersionNumb)


; Read settings.JSON for global settings
; FileRead, The_MemoryFile, % A_ScriptDir "\settings.json"
; Settings := JSON.parse(The_MemoryFile)
The_MemoryFile := ""


; Create some god vars
Download_array := []
UserInput_array := []
UserInput_file := A_ScriptDir "\input.txt"

Downloadurllead := "http://zbconline.com/wzbc-"



;/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\
; MAIN
;\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/



Loop
{
    ;;Read each line in the specified txt file
    FileReadLine, line, %UserInput_file%, %A_Index%
    if (ErrorLevel) {
        break
    }
    UserInput_array := StrSplit(line , "|")
    ; Loop, % UserInput_array.MaxIndex() {
    ;     Msgbox, % UserInput_array[A_Index]
    ; }

    ;; Generate every file to be downloaded
    ;; Step back in time as the user specifies "Monday, Tues, Wednesday"
    Date_StepVar := A_Now
    Date_StepVar += -336, hour ;Step back 2 weeks
    Loop, 336 {
        Date_StepVar += 1, hour
        FormatTime, dayoftheweekstring, %Date_StepVar%, ddd
        FormatTime, currentstephour, %Date_StepVar%, HH
        FormatTime, fulldateurlstring, %Date_StepVar%, yyyy-MM-dd-HH-00
        msgbox, % fulldateurlstring
        if (dayoftheweekstring = UserInput_array[1] && currentstephour = UserInput_array[1]) {
            slotdownloading_bool := true
        }

        if (slotdownloading_bool) {
            Download_array.push(Downloadurllead . fulldateurlstring . ".mp3")

            ;;stop recording if watch endtime is encountered
            if (currentstephour = UserInput_array[3]) {
                slotdownloading_bool := false
            }
        }
    }
    Date_StepVar += 1, day
    FormatTime, Date_Today, , yyyyMMddHHmmss
    msgbox, % Date_Today " vs " A_Now
}
return









;/--\--/--\--/--\--/--\--/--\
; Functions
;\--/--\--/--\--/--\--/--\--/




;/--\--/--\--/--\--/--\--/--\
; Subroutines
;\--/--\--/--\--/--\--/--\--/

;Create Directory and install needed file(s)
sb_InstallFiles()
{
    ; FileCreateDir, %A_ScriptDir%\data\
}

sb_TrayMenu()
{
	Global
	Menu, tray, NoStandard
    
	Menu, tray, add, %The_ProjectName% %The_VersionNumb%, Menu_Documentation
    if (A_IsCompiled) {
        Menu, tray, Icon, %The_ProjectName% %The_VersionNumb%, %A_ScriptDir%\%A_ScriptName%, 1, 0
    }
	Menu, tray, add, Documentation, Menu_Documentation
	Menu, tray, add, Quit, Quit
    ; Gui, Menu, tray
	return

	Menu_Documentation:
    Run https://github.com/Chunjee/SA-zbcdownloader
	return

	Quit:
    sb_ExitApp()
	exitapp
}


sb_ExitApp()
{
	global ;needs global acess to access log object

	log.add("GUI closed")

	log.add("Removing all registry changes")
	for key, value in Settings.optional_endings {
    	Fn_ContextMenuRemove("change name: ", value)
	}

	log.finalizeLog(The_ProjectName . " log completed.")
}


;/--\--/--\--/--\--/--\--/--\
; Functions
;\--/--\--/--\--/--\--/--\--/


Fn_SearchObj(para_obj, para_key)
{
    for l_key, l_value in para_obj {
        ; msgbox, % para_key " - " l_key
        if (para_key = l_key) {
            return l_value
        }
    }
}


Fn_ConextMenuAdd(para_title,para_arg)
{
    RegEntry := A_IsCompiled ? """" A_ScriptFullPath """ ""`%1####""" para_arg : """" A_AhkPath """ """ A_ScriptFullPath """ ""`%1####""" para_arg
    RegRead, ExistingEntry, HKey_Current_User, Software\Classes\*\shell\%para_title%\Command
    if (ExistingEntry = RegEntry) {
        RegDelete, HKey_Current_User, Software\Classes\*\shell\%para_title%%para_arg%
        RegDelete, HKey_Current_User, Software\Classes\Folder\shell\%para_title%%para_arg%
        RegDelete, HKEY_CLASSES_ROOT, lnkfile\%para_title%%para_arg%
        ; MsgBox, 0x40, %para_title%, Explorer context entry removed.
    } else {
        RegWrite, REG_SZ, HKEY_CURRENT_USER, Software\Classes\*\shell\%para_title%%para_arg%\Command, , %RegEntry%
        RegWrite, REG_SZ, HKEY_CURRENT_USER, Software\Classes\Folder\shell\%para_title%%para_arg%\Command, , %RegEntry%
        RegWrite, REG_SZ, HKEY_CLASSES_ROOT, lnkfile\%para_title%%para_arg%\Command, , %RegEntry%
        if A_IsCompiled {
            RegWrite, REG_SZ, HKEY_CURRENT_USER, Software\Classes\*\Shell\%para_title%%para_arg%,icon, %A_ScriptFullPath%
            RegWrite, REG_SZ, HKEY_CURRENT_USER, Software\Classes\Folder\shell\%para_title%%para_arg%,icon, %A_ScriptFullPath%
            RegWrite, REG_SZ, HKEY_CLASSES_ROOT, lnkfile\%para_title%%para_arg%,icon, %A_ScriptFullPath%
            }
        ; MsgBox, 0x40, %Title%, Explorer context entry added.
    }
}


Fn_ContextMenuRemove(para_title,para_arg)
{
    RegDelete, HKey_Current_User, Software\Classes\*\shell\%para_title%%para_arg%
    RegDelete, HKey_Current_User, Software\Classes\Folder\shell\%para_title%%para_arg%
    RegDelete, HKEY_CLASSES_ROOT, lnkfile\%para_title%%para_arg%
}
