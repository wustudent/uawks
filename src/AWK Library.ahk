#Include BrightnessSetter.ahk

;;
;; Wrapper Functions for Fn Sequences
;;

FnKey(NormalAction, FnAction, FnActionIsDefault = false)
{
	global FnKeyPressed
    SetKeyDelay, -1
    if (FnKeyPressed = FnActionIsDefault) {
		Send {Blind}%NormalAction%
	} else {
		Send {Blind}%FnAction%
	}
}

FnKeyCall(NormalAction, FnActionCall, FnArgs = "", FnActionIsDefault = false)
{
	global FnKeyPressed
    SetKeyDelay, -1
    if (FnKeyPressed = FnActionIsDefault) {
		Send {Blind}%NormalAction%
	} else {
        %FnActionCall%(FnArgs)
	}
}


;;
;; Wrapper Functions for Optional Features
;;

PreferenceKeyDown(normalKey, pref, prefKey) {
	global
	SetKeyDelay, -1
	if (%pref%) {
		Send {Blind}{%prefKey% Down}
	} else {
		Send {Blind}{%normalKey% Down}
	}
}

PreferenceKeyUp(normalKey, pref, prefKey) {
	global
	SetKeyDelay, -1
	if (%pref%) {
		Send {Blind}{%prefKey% Up}
	} else {
		Send {Blind}{%normalKey% Up}
	}
}

PreferenceKeyFnDown(normalKey, pref) {
	global
	SetKeyDelay, -1
	if (%pref%) {
		FnKeyPressed := true
	} else {
		Send {Blind}%normalKey%
	}
}

PreferenceKeyFnUp(normalKey, pref) {
	global
	SetKeyDelay, -1
	if (%pref%) {
		FnKeyPressed := false
	} else {
		Send {Blind}%normalKey%
	}
}


;;
;; Volume Overlay and Helpers
;;

VolumeMute(dummyVar="") {
    Send {Volume_Mute}
    GoSub, ProgressOff
    ;ShowVolume()
	VolumeOSD()
}

VolumeDown(dummyVar="") {
    global
    SoundSet, -%VolumeDownRate%, Master, Volume
	if (SyncWaveVolumeToMasterVolume) {
		SoundGet, MasterVolume, Master, Volume
		SoundSet, MasterVolume, Wave, Volume
	}
    ;ShowVolume()
    VolumeOSD()
}

VolumeUp(dummyVar="") {
    global
    SoundSet, +%VolumeUpRate%, Master, Volume
	if (SyncWaveVolumeToMasterVolume) {
		SoundGet, MasterVolume, Master, Volume
		SoundSet, MasterVolume, Wave, Volume
	}
    ;ShowVolume()
	VolumeOSD()
}

VolumeSet(NewVolume, UnMute = false) {
	global
    SoundSet, %NewVolume%, Master, Volume
	if (SyncWaveVolumeToMasterVolume) {
		SoundSet, %NewVolume%, Wave, Volume
	}
    if (UnMute) {
        ; Avoid flicker if already unmuted
        SoundGet, IsMuted, Master, Mute
        if (IsMuted = "On") {
            SoundSet, Off, Master, Mute
            GoSub, ProgressOff
        }
    }
    ;ShowVolume()
	VolumeOSD()
}

ProgressOff:
	SetWinDelay, -1
    SetTimer ProgressOff, Off
	Sleep, 30
	Progress, 1: Off
Return

ShowVolume() {
    global

    SoundGet, MasterVolume, Master, Volume
    SoundGet, WaveVolume, Wave, Volume
    
    IfWinNotExist, Master Volume
    {
        SoundGet, MasterMute, Master, Mute
        
        if (MasterMute = "on") {
            bgColor  = %MutedVolumeColorBg%
            barColor = %MutedVolumeColorBar%
        } else {
            bgColor  = %VolumeColorBg%
            barColor = %VolumeColorBar%
        }
        SetWinDelay, -1
		ColorStr = cw%bgColor% ct0000CC cb%barColor%
		SizeStr  =  h%OverlayHeight% w%OverlayWidth% zh%OverlayHeight% zx0 zy0
        Progress, 1: p%MasterVolume% b %SizeStr% %ColorStr%, , , Master Volume, Arial
        
		WinSet, Transparent, %OverlayTransparency%, Master Volume

        ;WinGetPos, X1, Y1, Width1, Height1, Master Volume
		if not OverlayDisplayCentered {
			WinMove, Master Volume, , 0, 0
		}
    }
    else
    {
        Progress, 1: %MasterVolume%
    }

    SetTimer ProgressOff, %OverlayDisplayTime%
}

ActiveWindowIsAMediaPlayer() {
	SetTitleMatchMode RegEx
	IfWinActive, ^Windows Media Player$
		Return true
	IfWinActive, ahk_class iTunes
		Return true
	IfWinActive, ahk_class MediaPlayerClassicW
		Return true
	Return false
}

;;
;; Media Key Support
;;

MediaCommandPrev(dummyVar="") {
    if (ActiveWindowIsAMediaPlayer()) {
		GoTo SendMediaCommandPrev
	}
	
	IfWinExist, ahk_class iTunes
	{
		ControlSend, ahk_parent, ^{Left}^{Left}
		return
	}
	
	SendMediaCommandPrev:
		Send, {Media_Prev}
}

MediaCommandPlay(dummyVar="") {
    if (ActiveWindowIsAMediaPlayer()) {
		GoTo SendMediaCommandPlay
	}
	
	IfWinExist, ahk_class iTunes
	{
		ControlSend, ahk_parent, ^{Space}
		return
	}
	
	SendMediaCommandPlay:
		Send, {Media_Play_Pause}
}

MediaCommandNext(dummyVar="") {
    if (ActiveWindowIsAMediaPlayer()) {
		GoTo SendMediaCommandNext
	}
	
	IfWinExist, ahk_class iTunes
	{
		ControlSend, ahk_parent, ^{Right}
		return
	}
	
	SendMediaCommandNext:
		Send, {Media_Next}
}


VolumeOSD() {
	try if ((shellProvider := ComObjCreate("{C2F03A33-21F5-47FA-B4BB-156362A2F239}", "{00000000-0000-0000-C000-000000000046}"))) {
				try if ((flyoutDisp := ComObjQuery(shellProvider, "{41f9d2fb-7834-4ab6-8b1b-73e74064b465}", "{41f9d2fb-7834-4ab6-8b1b-73e74064b465}"))) {
					 DllCall(NumGet(NumGet(flyoutDisp+0)+3*A_PtrSize), "Ptr", flyoutDisp, "Int", 0, "UInt", 0)
					,ObjRelease(flyoutDisp)
				}
				ObjRelease(shellProvider)
	}
}

BrightnessUp(dummyVar="") {
    BrightnessSetter.SetBrightness(+3)
}

BrightnessDown(dummyVar="") {
	BrightnessSetter.SetBrightness(-3)
}

OpenTaskManager(){
	run taskmgr.exe
}