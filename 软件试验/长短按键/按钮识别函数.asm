	LIST	P=16F716
	INCLUDE	P16F716.INC
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

;写AD转换控制字
	BCF		STATUS,RP0			;体0
	MOVLW	B'01000001'			;D7 D6=01 AD转换时钟频率= FOSC/8
	MOVWF	ADCON0				;D5 D4 D3=000 AD转换模拟通道选择RA0/AN0
	BSF		STATUS,RP0			;体1
	MOVLW	B'00001110'			;D3 D2 D1 D0 1110选择RA0为模拟口。
	MOVWF	ADCON1				;D7=0左对齐 ADRESL的低六位读作0
	CLRF	ADRES
;----------------------------------------------------------
;函数名称：KEY_SCAN
;输入参数：无
;输出参数：按键值 Key_Record
;功能描述：按键扫描，每500us扫描一次，总共扫描50次
;----------------------------------------------------------
Key_Scan
	CALL	Delay_500us			;延时500us扫描
	MOVLW	50					;扫描50次计数
	MOVWF	Key_AD_Count
	BCF		STATUS,RP0			;体0
	BSF		ADCON0,2			;开启A/D
Wait_AD
	BTFSS	PIR1,6				;等待A/D完成
	GOTO	Wait_AD
	MOVF	ADRES,W				;A/D值到W
	XORWF	Key_Record,W		;新旧按键值对比
	BTFSC	STATUS,Z			;测试异或结果
	GOTO	NO_Recount			;如果相同不重置计数
	MOVLW	50					;重置计数
	MOVWF	Key_AD_Count
NO_Recount
	MOVF	ADRES,W				;更新按键记录
	MOVWF	Key_Record
	RETURN						;函数返回

Delay_500us:
	MOVLW	((500 - 2) / 3)
	MOVWF	Wait_500_Cnt
Wait_500
	DECFSZ	Wait_500_Cnt,1
	GOTO	Wait_500
	RETURN

	END

