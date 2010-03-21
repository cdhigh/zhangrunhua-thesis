;实验目的：熟悉RB口电平变化中断功能的使用
;软件规划：
;         1，只取下降沿触发的中断；上升沿中断直接返回
;         2，按RB4一次，输出加1
;         3，按RB5一次，输出减1
;         4，RC口LED做输出结果显示
; 硬件规划：
;         1，使能内部弱上拉
;         2，RB4和RB5接按键
;         3；C口LED灯做结果显示。
LIST P=16F877
INCLUDE "P16F877a.INC"
;------------------------------------------------------------------------------------------
PORTC_TEP  EQU  31H
W_TEMP     EQU  32H
STATUS_TEM EQU  33H

   ORG  00H
   NOP
   GOTO   ST
;------------------------------------------------------------------------------------------
; 中断服务程序
;------------------------------------------------------------------------------------------
   ORG     04H
   MOVWF   W_TEMP
   MOVF   STATUS
   MOVWF   STATUS_TEM

   BCF     INTCON,RBIF      ;清除RB中断标志位
   BTFSS   PORTB,4          ;RB4是否按下？
   GOTO    RB4
   BTFSS   PORTB,5          ;RB5是否按下？
   GOTO    RB5

RE         MOVF   STATUS_TEM       ;中断返回
   MOVWF   STATUS
   SWAPF   W_TEMP,1
   SWAPF   W_TEMP,0
   RETFIE                  
RB4       
   BTFSS   PORTB,4          ;等待RB4释放
   GOTO    RB4
   INCF    PORTC_TEP,1      ;输出加1
   GOTO    RE
RB5       
   BTFSS   PORTB,5          ;等待RB5释放
   GOTO    RB5
   DECF    PORTC_TEP,1      ;输出减1
   GOTO    RE
;------------------------------------------------------------------------------------------
; 主程序
;------------------------------------------------------------------------------------------
ST         BSF     STATUS,RP0       ;选择数据存储器体1
   CLRF    OPTION_REG       ;开启内部弱上拉
   MOVLW   00H
   MOVWF   TRISC            ;RC端口为输出
   MOVLW   30H
   MOVWF   TRISB            ;R4,R5为输入
   BCF     STATUS,RP0       ;选择数据存储器体0
   MOVLW   88H
   MOVWF   INTCON           ;总中断和RB中断使能
   CLRF    PORTB
   CLRF    PORTC            ;PORTC输出清零
   CLRF    PORTC_TEP        ;临时PORTC清零
   MOVLW   00H
   MOVWF   PORTC            ;PORTC输出清零
   CALL    DELAY1           ;延时
LOOP       MOVF    PORTC_TEP,W      ;取出临时PORTC清零
   MOVWF   PORTC            ;临时PORTC加载
   CALL    DELAY1           ;延时
   GOTO    LOOP             ;返回
;------------------------------------------------------------------------------------------
; 延时子程序
;------------------------------------------------------------------------------------------
DELAY1 
   MOVLW   3FH              ;外循环常数
   MOVWF   20H              ;外循环寄存器
L1         MOVLW   02H      ;内循环常数
   MOVWF   21H              ;内循环寄存器
L2         DECFSZ  21H,1    ;内循环寄存器递减
   GOTO    L2               ;继续内循环
   DECFSZ  20H,1            ;外循环寄存器递减
   GOTO    L1               ;继续外循环
   RETURN                   ;子程序返回
;------------------------------------------------------------------------------------------
END
;----------------------------------------------------------