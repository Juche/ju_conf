#InstallKeybdHook

/*
windows自带输入法的id,可以通过调用windows api GetKeyboardLayout来获取
微软拼音输入法 134481924
微软日文输入法 68224017
微软英文输入法 67699721
*/
; IMEmap:=Map(
; "zh",134481924,
; "en",67699721
; )
; enAppList :=[
; "pwsh.exe"
; ]
; 获取当前激活窗口所使用的IME的ID
; getCurrentIMEID(){
;     winID:=winGetID("A")
;     ThreadID:=DllCall("GetWindowThreadProcessId", "UInt", WinID, "UInt", 0)
;     InputLocaleID:=DllCall("GetKeyboardLayout", "UInt", ThreadID, "UInt")
;     return InputLocaleID
; }
; ; 使用IMEID激活对应的输入法
; switchIMEbyID(IMEID){
;     ; winTitle:=WinGetTitle("A")
;     ; PostMessage(0x50, 0, IMEID,, WinTitle )
;     ; WinGetTitle, winTitle, A
;     PostMessage, 0x50, 0, %IMEID%,, A
;     ; WinGetTitle, Title, A
;     ; MsgBox, The active window is "%Title%".
;     ; PostMessage, 0x50, 0, %IMEID%,, %WinTitle%
; }

; ; 切换微软拼音输入法
; CapsLock & 1::{
;     switchIMEbyID(IMEmap["zh"])
;     ; SetCapsLockState "alwaysoff"
; }
; ; 切换微软英文键盘
; CapsLock & 2::{
;     switchIMEbyID(IMEmap["en"])
;     ; SetCapsLockState "alwaysoff"
; }

; ; 使用窗口组实现批量窗口的监视
; GroupAdd "enAppGroup", "ahk_exe Code.exe" ;添加 vscode
; GroupAdd "enAppGroup", "ahk_exe pwsh.exe" ;添加powershell
; GroupAdd "enAppGroup", "ahk_exe WindowsTerminal.exe" ;添加windows terminal
; ; 循环等待知道窗口组的窗口激活，切换当前输入法为en,之后再等待当切换出当前窗口继续监视
; Loop{
;     WinWaitActive "ahk_group enAppGroup"
;     currentWinID:= WinGetID("A")
;     ; TrayTip Format("当前是{1}，切换为en输入法", WinGetTitle("A"))
;     switchIMEbyID(IMEmap["en"])
;     ; 从当且窗口切出，进行下一轮监视
;     WinWaitNotActive(currentWinID)
; }

; #HotIf WinActive("ahk_exe Code.exe") or WinActive("ahk_exe nvim.exe") or WinActive("ahk_exe nvim-qt.exe")
; #HotIf
; if WinActive("ahk_exe Code.exe") or WinActive("ahk_exe nvim.exe") or WinActive("ahk_exe nvim-qt.exe")

; TODO: 判断当前输入法为中文还是英文
; TODO: 限定指定软件(Vim 操作模式的)使用定制按键映射
; TODO: CapLock 按键 在 vscode 中执行 ctrl + s => 可以格式化代码 & 光标位置不会跳
toggleIME(){
    Send, {Shift}
}

GroupAdd vimGroup, ahk_exe Code.exe
GroupAdd vimGroup, ahk_exe nvim.exe
GroupAdd vimGroup, ahk_exe nvim-qt.exe
#IfWinActive ahk_group vimGroup
    SetCapsLockState, alwaysoff
    Capslock::
        Send {LControl Down}
        KeyWait, CapsLock
        Send {LControl Up}
        if ( A_PriorKey = "CapsLock" )
        {
            $Esc::
                ; 0x0050 is WM_INPUTLANGCHANGEREQUEST
                ; PostMessage, 0x50, 0, 0x8040804, , A ;切换为输入法的默认输入状态
                PostMessage, 0x50, 0, 0x4090409, , A ;切换为英文0x4090409=67699721
            ^Esc::
                ; switchIMEbyID(IMEmap["en"])
                ; switchIMEbyID(67699721)
                ; send, {LControl Down}{s}{LControl Up}
                ; send, {LControl Down}{s}{LControl Up}
                ; 适配vim通用操作
                Send, {Esc}
                send, {:w!}{Enter}
                PostMessage, 0x50, 0, 0x4090409, , A ;切换为英文0x4090409=67699721
                ; toggleIME()
            return
        }

        return
