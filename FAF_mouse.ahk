; Sometimes this doesn't work well, it can get stuck after releasing until you click again.

#NoEnv
SendMode Input
SetWorkingDir %A_ScriptDir%
#Persistent

SetTimer, KeepRunning
return

KeepRunning:

  WinGet, szProcessName, ProcessName, A
  if szProcessName = ForgedAlliance.exe
  {
    Suspend, off
  }
  else
  {
    Suspend, on
  }
return

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