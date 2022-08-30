#InstallKeybdHook
SetCapsLockState, alwaysoff
Capslock::
    Send {LControl Down}
    KeyWait, CapsLock
    Send {LControl Up}
    if ( A_PriorKey = "CapsLock" )
    {
        $Esc::
            PostMessage, 0x50, 0, 0x8040804, , A ;切换为输入法的默认输入状态
            PostMessage, 0x50, 0, 0x4090409, , A ;切换为英文0x4090409=67699721
        ^Esc::
            send, {LControl Down}{s}{LControl Up}
            Send, {Esc}
        return
    }
    return
