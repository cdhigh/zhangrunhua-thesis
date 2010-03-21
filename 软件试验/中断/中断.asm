LIST	P=16F818
INCLUDE	P16F818.INC
W_TEMP		EQU	32H
STATUS_TEM	EQU	33H
	ORG		0x00
	NOP
	GOTO	MAIN			;转向主程序
	ORG 	0x04
	GOTO	INTSERVE		;转向中断服务子程序
;----------------------------------------------------------
;函数名称：中断服务程序
;功能描述：开关电源
;----------------------------------------------------------
INTSERVE
	MOVWF	W_TEMP			;保存w
	MOVF	STATUS,0		;保存STATUS
	MOVWF	STATUS_TEMP
	BTFSC	PIR1,ADIF		;判断是否AD中断
	GOTO	INTSERVE_AD_END	;不是则不进行AD中断程序
;AD中断服务程序
INTSERVE_AD
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
	CALL	Action_Vol_Fall
	GOTO	Key_OK_End

	MOVF	Key_Record,0
	XORLW	Key_Vol_Rise			;将Key_Record与Key_Vol_Rise对比
	BTFSS	STATUS,Z				;测试结果是否0
	CALL	Action_Vol_Rise
	GOTO	Key_OK_End

	MOVF	Key_Record,0
	XORLW	Key_Vol_Slient			;将Key_Record与Key_Vol_Slient对比
	BTFSS	STATUS,Z				;测试结果是否0
	CALL	Action_Vol_Slient
Key_OK_End

INTSERVE_AD_END

RE	MOVF	STATUS_TEM       ;中断返回
	MOVWF	STATUS
	SWAPF	W_TEMP,1
	SWAPF	W_TEMP,0
	RETFIE
	BCF		PIR1,ADIF		;清除外设中断请求寄存器
MAIN
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
;写AD转换控制字
	BSF		STATUS,RP0			;体1
	MOVLW	B'00001110'			;D3 D2 D1 D0 1110选择RA0为模拟口。
	MOVWF	ADCON1				;D7=0左对齐 ADRESL的低六位读作0
	BCF		STATUS,RP0			;体0
	MOVLW	B'01000001'			;D7 D6=01 AD转换时钟频率= FOSC/8
	MOVWF	ADCON0				;D5 D4 D3=000 AD转换模拟通道选择RA0/AN0