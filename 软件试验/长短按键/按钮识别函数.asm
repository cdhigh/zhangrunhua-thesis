	LIST	P=16F818
	INCLUDE	P16F818.INC

#define		Key_Vol_Rise	1300
#define		Key_Vol_Fall	1300
#define		Key_Vol_Slient	1300
#define		Key_Power		1300
Main_Status		EQU	0x10		;B7:电源状态;B6:喇叭继电器;B5:音量升降标志
Key_Record		EQU	0x1D
Key_AD_Count	EQU	0x1E
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
;函数名称：Key_Act
;输入参数：
;输出参数：
;功能描述：按键对应操作。
;----------------------------------------------------------
Key_Act
	CALL	Key_Scan
	MOVF	Key_AD_Count,0
	XORWF	50						;将扫描次数与50对比
	BTFSS	STATUS,Z				;测试结果是否0
	GOTO	Key_OK_End
	BTFSS	Key_Record,0			;测试扫描成功位置是否1
	GOTO	Key_OK_End				;扫描失败跳到Key_OK_End
	;检测按键成功，分离操作
	MOVF	Key_Record,0
	XORLW	Key_Power				;将Key_Record与Key_Power对比
	BTFSS	STATUS,Z				;测试结果是否0
	CALL	Action_Power_OnOff
	GOTO	Key_OK_End

	MOVF	Key_Record,0
	XORLW	Key_Vol_Fall			;将Key_Record与Key_Vol_Fall对比
	BTFSS	STATUS,Z				;测试结果是否0
	BCF		Main_Status,5			;升降音量设为降
	BCF		Main_Status,4			;不使用音量直调
	CALL	Action_Vol
	GOTO	Key_OK_End

	MOVF	Key_Record,0
	XORLW	Key_Vol_Rise			;将Key_Record与Key_Vol_Rise对比
	BTFSS	STATUS,Z				;测试结果是否0
	BCF		Main_Status,4			;不使用音量直调
	BSF		Main_Status,5			;升降音量设为升
	CALL	Action_Vol
	GOTO	Key_OK_End

	MOVF	Key_Record,0
	XORLW	Key_Vol_Slient			;将Key_Record与Key_Vol_Slient对比
	BTFSS	STATUS,Z				;测试结果是否0
	CALL	Action_Vol_Slient
Key_OK_End

	END
