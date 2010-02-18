	LIST	P=16F818
	INCLUDE	P16F818.INC
Main_Status	EQU	0x10			;B7:电源状态;B6:喇叭继电器
;初始化
	ORG	0x00
	BSF		STATUS,RP0
	MOVLW	B'00001111'
	MOVWF	TRISA
	MOVLW	B'00000000'
	MOVWF	TRISB
	BCF		STATUS,RP0
	CLRF	PORTA
	CLRF	PORTB
;----------------------------------------------------------
;函数名称：Action_Power_OnOff
;输入参数：
;输出参数：
;功能描述：开关电源
;----------------------------------------------------------
Action_Power_OnOff
	BTFSS	Main_Status,7
	BSF		PORTB,1					;B1电源控制接点
	BTFSC	Main_Status,7
	BCF		PORTB,1					;B1电源控制接点
	MOVLW	B'10000000'				;将Main_Status最高位取反
	XORWF	Main_Status,1
	RETURN
	END
