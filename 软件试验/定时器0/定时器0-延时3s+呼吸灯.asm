	LIST	P=16F716
	INCLUDE	P16F716.INC
Delay_3s_Cnt	EQU	0x1F
	ORG	0x00
	NOP
;初始化
	ORG	0x00
;----------------------------------------------------------
;函数名称：Delay_3s
;功能描述：延时3秒启动系统，期间呼吸灯闪4次
;----------------------------------------------------------
Delay_3s
	BSF		OPTION_REG,0			;分频比256
	BSF		OPTION_REG,1			;分频比256
	BSF		OPTION_REG,2			;分频比256	
	BCF		INTCON,T0IF				;将T0IF清0
	MOVLW	0xE5					;76,循环1s
	CLRF	TMR0					;重置TMR0
	MOVWF	Delay_3s_Cnt
Delay_3s_1	BTFSS	INTCON,T0IF		;Timer0溢出否?
	GOTO	Delay_3s_1				;否!返回上一步
	;呼吸灯开始
	BTFSC	Delay_3s_Cnt,6			;3秒内,呼吸灯闪4次
	BCF		PORTB,1
	BTFSS	Delay_3s_Cnt,6
	BSF		PORTB,1
	;呼吸灯结束
	DECFSZ	Delay_3s_Cnt,1			;减一次Delay_3s_Cnt,到0跳下句
	GOTO	Delay_3s_1				;继续Delay_3s_1
	END