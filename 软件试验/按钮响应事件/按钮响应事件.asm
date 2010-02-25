	LIST	P=16F818
	INCLUDE	P16F818.INC
Main_Status		EQU	0x10		;B7:电源状态;B6:喇叭继电器;B5:音量升降标志;B4:音量直调标志
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
	BTFSC	Main_Status,7
	BSF		PORTB,1					;B1电源控制接点
	BTFSS	Main_Status,7
	BCF		PORTB,1					;B1电源控制接点
	MOVLW	B'10000000'				;将Main_Status最高位取反
	XORWF	Main_Status,1
	RETURN
;----------------------------------------------------------
;函数名称：Action_Vol
;输入参数：音量Volume_Data;Main_Status,5:音量升降标志;Main_Status,6:音量直调标志
;输出参数：
;功能描述：音量调整
;----------------------------------------------------------
Action_Vol
	;音量直调
	BTFSC	Main_Status,4			;判断是否音量直接调整
	GOTO	Vol_Set_End
	;音量步进
	BTFSC	Main_Status,5			;判断音量升降
	INCF	Volume_Data,1			;Volume_Data值自加1
	BTFSS	Main_Status,5			;判断音量升降
	DECF	Volume_Data,1			;Volume_Data值自减1
Vol_Set_End
	CALL	SET_Volume				;调用SET_Volume驱动M64629
	MOVF	Volume_Data				;将当前音量值复制到
	MOVWF	LED_Data
	CALL	LED_Display				;显示数字
	RETURN
	END
