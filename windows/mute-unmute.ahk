#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

; SoundVolumeView: https://www.nirsoft.net/utils/sound_volume_view.html
; SVCL (command line version): https://www.nirsoft.net/utils/sound_volume_command_line.html

; Path to SVCL.
SvclPath := "W:\bin\svcl-x64\svcl.exe"
; Configure this to the name of the microphone in SoundVolumeView.
MicName := "Focusrite USB Audio\Device\Analogue 1 + 2\Capture"

; Make sure the state of SCRLK is correct when starting this script.
ToggleScrlk()

; The user may toggle the state of SCRLK, e.g. if the LED is annoying.

MuteMic() {
  global SvclPath, MicName
  ; Starts SoundVolumeView which toggles the state of the microphone.
  ; Just create this link from within the application.
  RunWait %SvclPath% /Switch "%MicName%", ,hide
}

ToggleScrlk() {
  global SvclPath, MicName
  ; send, {sc046}
  ; Sleep 25
  ; send, {sc046}
  RunWait %SvclPath% /GetMute "%MicName%", , hide
  ; MsgBox % GetKeyState("Scrolllock", "T")
  if (ErrorLevel = 0 and GetKeyState("Scrolllock", "T") = 1) {
    ; microphone is not muted, scrlk enabled, turn it off
    send, {sc046}
  }
  else if (ErrorLevel = 1 and GetKeyState("Scrolllock", "T") = 0) {
    ; microphone is muted, scrlk disable, turn it on
    send, {sc046}
  }
}

; Start mute/unmute application on PAUSE (or SCRLK) keypress
Pause::
; sc046::
MuteMic()
ToggleScrlk()
Return
