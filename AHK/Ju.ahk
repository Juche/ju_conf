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
; toggleIME(){
;     Send, {Shift}
; }

GetIME()
{ ; 获取当前窗口的活动输入法语言布局ID接口, 该接口是为数不多能个正确的查询到输入法语言状态的接口
    IMECode:=DllCall("GetKeyboardLayout", "UInt", DllCall("GetWindowThreadProcessId", "UInt", WinActive("A"), "UInt", 0), "UInt")
    MsgBox, The IME Code is "%IMECode%".
    return IMECode
}

SwitchIME()
{ ; 切换输入法
    global ime_us_cn_point
    if (GetIME() = 0x8040804) ; = 0x8040804 = 中文
        SendMessage, 0x50, 0, 0x00000409, , A
    else
    {
        SendMessage, 0x50, 0, 0x00000804, , A
    }
}

GroupAdd vimGroup, ahk_exe Code.exe
GroupAdd vimGroup, ahk_exe nvim.exe
GroupAdd vimGroup, ahk_exe nvim-qt.exe

; 全局使用 Shift 和 CapsLock 切换中英文
Shift::
    PostMessage, 0x50, 0, 0x8040804, , A ;切换为输入法的默认状态(中文)
Return
Capslock::
    SetCapsLockState, alwaysoff
    PostMessage, 0x50, 0, 0x4090409, , A ;切换为英文0x4090409=67699721

    ; 在 vim 系使用 CapsLock 回到 Normal 模式 & 保存,同时也切换到了英文输入模式
    ; #IfWinActive ahk_group vimGroup
    if(WinActive("ahk_group vimGroup"))
    {
        Send, {Esc}
        send, {LControl Down}{s}{LControl Up}
        return
    }

return
;     SetCapsLockState, alwaysoff
;     ; Shift::
;     ;     ; Send {LWin Down}{Space}{LWin Up}
;     ;     ; SwitchIME()
;     ;     PostMessage, 0x50, 0, 0x8040804, , A ;切换为输入法的默认输入状态
;     ; return
;     Capslock::
;         Send, {Esc}
;         send, {LControl Down}{s}{LControl Up}
;         ; PostMessage, 0x50, 0, 0x4090409, , A ;切换为英文0x4090409=67699721
;     return
; Capslock::
;     Send {LControl Down}
;     KeyWait, CapsLock
;     Send {LControl Up}
;     if ( A_PriorKey = "CapsLock" )
;     {
;         $Esc::
;             ; 0x0050 is WM_INPUTLANGCHANGEREQUEST
;             ; PostMessage, 0x50, 0, 0x8040804, , A ;切换为输入法的默认输入状态
;             PostMessage, 0x50, 0, 0x4090409, , A ;切换为英文0x4090409=67699721
;         ^Esc::
;             ; switchIMEbyID(IMEmap["en"])
;             ; switchIMEbyID(67699721)
;             send, {LControl Down}{s}{LControl Up}
;             ; 适配vim通用操作
;             ; Send, {Esc}
;             ; send, {:w!}{Enter}
;             ; PostMessage, 0x50, 0, 0x4090409, , A ;切换为英文0x4090409=67699721
;             ; toggleIME()
;         return
;     }

;     return
