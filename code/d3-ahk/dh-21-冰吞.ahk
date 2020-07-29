#IfWinActive, ahk_class D3 Main Window Class
#SingleInstance force ;只能启动一个ahk程序实例，防止重复启动

; 1    追踪箭
; 2    扫射     (映射w键位)
; 3    烟雾弹(小米), 暗影之力(大米)
; 4    复仇
; 左键 宠物
; 右键 蓄势待发
; x    药水

; 使用方法，按一次鼠标中键启动宏
;   0 表示关闭
;   1 表示小米
;   2 表示大米
global masterFlag := 0
; 1为进入烟雾弹状态，0为未进入烟雾弹状态，为1的时候将不会按追踪箭
global smokeScreenState := 0


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
    ; 程序如果是启动模式，
    ;   则一直检测（扫射）是否按下，
    ;   如果（扫射）是按下的情况，
    ;       则按一次（烟雾弹）（复仇）（蓄势待发），并且一直循环按1号键
    if (masterFlag = 0) {
        masterFlag = 1

        SetTimer, CheckPickState, 110
        SetTimer, CheckStrafeState, 650
        SetTimer, ReleaseHungeringArrow, 1400
        SetTimer, ReleaseSmokeScreen, 2800
    } else if (masterFlag = 1) {
        masterFlag = 2

        SetTimer, CheckPickState, 220
        SetTimer, ReleaseSmokeScreen, off
        SetTimer, ReleaseHungeringArrow, 1600
        SetTimer, ReleaseShadowPower, 4900
    } else {
        stopAll()
    }

    inTown = 0
}
return

~Enter::    ;回车打字关闭技能和购买分解宏
{
    stopAll()
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
    smokeScreenState = 0

    SetTimer, CheckPickState, off
    SetTimer, CheckStrafeState, off
    SetTimer, ReleaseHungeringArrow, off
    SetTimer, ReleaseSmokeScreen, off
    SetTimer, ReleaseShadowPower, off
}

isRunning() {
    if (GetKeyState("CapsLock", "T") = 1) {
        return 1
    }
    if (GetKeyState("w", "P") = 1) {
        return 1
    }
    return 0
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

; 如果（扫射）是按下的情况，
;   则按一次（复仇）（蓄势待发）
CheckStrafeState:
{
    if (isRunning() = 1) {
        sleepWhile(10, 60)
        Send, 4
        Click, Right, 1     ; 点击鼠标右键一次
        ; Send, {x}
    }
}
return

;检测（扫射）是否是按下的
;   如果（扫射）是按下的，则按一次1号键
;   否则啥也不做
ReleaseHungeringArrow:
{
    if (isRunning() = 1) {
        if (masterFlag = 1 && smokeScreenState = 0) {
            sleepWhile(10, 60)
            Send, 1
        } else if (masterFlag = 2) {
            sleepWhile(10, 60)
            Send, 1
        }
    }
}
return

; 释放烟雾弹，并把烟雾弹状态改为1，1秒后重置为0
ReleaseSmokeScreen:
{
    if (isRunning() = 1) {
        sleepWhile(10, 60)
        Send, 3
        smokeScreenState = 1
        SetTimer, SetSmokeScreenStateZero, -1000
    }
}
return

;把烟雾弹状态置为0
SetSmokeScreenStateZero:
{
    smokeScreenState = 0
}
return

ReleaseShadowPower:
{
    if (isRunning() = 1) {
        sleepWhile(10, 60)
        Send, 3
    }
}
return
