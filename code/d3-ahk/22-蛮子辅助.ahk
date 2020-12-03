#IfWinActive, ahk_class D3 Main Window Class
#SingleInstance force ;只能启动一个ahk程序实例，防止重复启动

; 1    战吼
; 2    冲撞
; 3    战吼
; 4    巨怪
; 左键 盾墙
; 右键 钩子

SetKeyDelay, 50
SetMouseDelay, 50

; 使用方法，按一次鼠标中键启动宏
;   0 表示关闭
;   1 表示开启
global masterFlag := 0


global inTown := 0
global PAutoBuyInterval := 50             ;自动购买间隔, 默认50毫秒
global PAutoBuyQuantity := 30             ;自动购买次数，默认30次

; 监听PgUp，按下中键则会执行大括号里面的程序
$PgUp::
{
    if (inTown = 0) {
        inTown = 1
    } else {
        inTown = 0
    }
}
return

; 按D分解一次装备
~D::
{
    if (inTown = 1) {
        Click
        Send, {Enter}
    }
}
return

; 购买
~F::
~B::
{
    if (inTown = 1) {
        Loop, %PAutoBuyQuantity% {
            Click, Right, 1
            Sleep, %PAutoBuyInterval%
        }
    }
}
return


; 监听MButton，按下中键则会执行大括号里面的程序
$MButton::
{
    if (masterFlag = 0) {
        masterFlag = 1
        SetTimer, KeepBuff, 1110
        SetTimer, CheckPickState, 220
    } else {
        stopAll()
    }

    inTown = 0
}
return

~Enter::    ;回车打字关闭技能和购买分解宏
{
    stopAll()
    sleepWhile(30, 59)
    inTown = 0
}
return

~T::        ;按T回城技能宏, 打开购买分解宏
{
    stopAll()
    inTown = 1
}
return

sleepWhile(min, max) {
    ranSleep := 0
    Random, ranSleep, %min%, %max%
    Sleep, %ranSleep%
}

stopAll() {
    masterFlag = 0
    SetTimer, KeepBuff, off
    SetTimer, CheckPickState, off
}

; 按住A拾取
CheckPickState:
{
    state := GetKeyState("a", "P")
    if (state = 1) {
        Loop, 10 {
            sleepWhile(3, 8)
            Click
        }
    }
}
return

KeepBuff:
{
    sleepWhile(3, 8)
    Send, 1
    sleepWhile(3, 8)
    Send, 3
    sleepWhile(3, 8)
    Send, Left, 2
}
return


~=::Pause  ;宏暂停或继续
