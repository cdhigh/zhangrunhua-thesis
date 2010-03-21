	LIST	P=16F818
	INCLUDE	P16F818.INC
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
;函数名称：Auto_Vol
;输入参数：
;输出参数：
;功能描述：自动调整音量。
;----------------------------------------------------------
Auto_Vol
	CALL	Read_Curr_Vol
	
	END
