LWin & t:: {                          ; Alt + t
    t := WinGetTitle("A")
    ExStyle := WinGetExStyle(t)
    if (ExStyle & 0x8) {            ; 0x8 is WS_EX_TOPMOST
        WinSetAlwaysOnTop 0, t      ; Turn OFF and remove Title_When_On_Top
        ToolTip "Top OFF"
        SetTimer(ToolTip, 1000)
    }
    else {
        WinSetAlwaysOnTop 1, t      ; Turn ON and add Title_When_On_Top
        ToolTip "Top ON"
        SetTimer(ToolTip, 1000)

    }
}

Workspace(num) {
    ;; https://github.com/MScholtes/VirtualDesktop
    RunWait(format("d:/Tools/cmd/VirtualDesktop.exe /Switch:{}", num), , "Hide")
}

LWin & 1:: Workspace(0)
LWin & 2:: Workspace(1)
LWin & 3:: Workspace(2)
LWin & 4:: Workspace(3)
LWin & 5:: Workspace(4)
LWin & 6:: Workspace(5)
LWin & 7:: Workspace(6)
LWin & 8:: Workspace(7)

; 现在物理 CapsLock 键已经变成了 F24
; 我们不再需要 CapsLock::Return 了，因为 F24 本来就不会切换大写
; --- 导航与移动 ---
F24 & f::Send("{Blind}{Right}")
F24 & b::Send("{Blind}{Left}")
F24 & p::Send("{Blind}{Up}")
F24 & n::Send("{Blind}{Down}")
F24 & a::Send("{Blind}{Home}")
F24 & e::Send("{Blind}{End}")
; --- 删除与编辑 ---
F24 & h::Send("{Blind}{Backspace}")
F24 & d::Send("{Blind}{Delete}")
F24 & k::Send("{ShiftDown}{End}{ShiftUp}{Delete}")
F24 & u::Send("^z")
F24 & r::Send("^y")
; --- 剪贴板与常用 ---
F24 & w::Send("^x")
F24 & y::Send("^v")
F24 & s::Send("^f")
!w::Send("^c")
F24 & m::Send("{Enter}")
F24 & g::Send("{Esc}")
