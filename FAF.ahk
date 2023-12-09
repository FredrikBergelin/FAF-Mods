#NoEnv
SendMode Input
SetWorkingDir %A_ScriptDir%
#Persistent

procName := "ForgedAlliance.exe"
SetTimer, CheckProc, 2000
Return

CheckProc:
    If (!ProcessExist(procName))
        Return
      
      
    WinGet Style, Style, % "ahk_exe " procName
    If (Style & 0xC40000)
    {
        WinSet, Style, -0xC40000, % "ahk_exe " procName
        WinMinimize, % "ahk_exe " procName
        WinMaximize, % "ahk_exe " procName
      Run, %comspec% /c process -a forgedalliance.exe 111111111110
      Run, %comspec% /c process -p forgedalliance.exe high
    }

ProcessExist(exeName)
{
   Process, Exist, %exeName%
   return !!ERRORLEVEL
}
return

$LWin::LCtrl

XButton2::
+XButton2::
!XButton2::
^XButton2::
+!XButton2::
+^XButton2::
    while GetKeyState("XButton2", "P")
    {
        MouseClick, Left
        Sleep 60
    }
return

XButton1::
+XButton1::
!XButton1::
^XButton1::
+!XButton1::
+^XButton1::
    while GetKeyState("XButton1", "P")
    {
        MouseClick, Right
        Sleep 60
    }
return

Return
