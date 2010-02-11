	LIST	P=16F716
	INCLUDE	P16F716.INC
Delay_3s_Cnt	EQU	0x1F
	ORG	0x00
	NOP
;初始化
	ORG	0x00
	MOVLW	B'11000111'				;分频比256
	MOVWF	OPTION_REG

Delay_3s
	BCF	INTCON,T0IF					;将T0IF清0
	CLRF	TMR0
	MOVLW	0xFF
	MOVWF	Delay_3s_Cnt
Delay_3s_1	BTFSS	INTCON,T0IF		;Timer0溢出否?
	GOTO	Delay_3s_1				;否!返回上一步
	DECFSZ	Delay_3s_Cnt,1			;减一次Delay_3s_Cnt,到0跳下句
	GOTO	Delay_3s_1				;继续Delay_3s_1
	RETURN							;是!返回子程序调用
	
	END