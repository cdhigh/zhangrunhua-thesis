	LIST	P=16F818
	INCLUDE	P16F818.INC
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
;函数名称：Key_Scan
;输入参数：原有按键时间值Key_AD_Count
;输出参数：按键值 Key_Record，按键时间值Key_AD_Count
;功能描述：按键扫描，扫描一次，总共次数累计于Key_AD_Count。如果结果不为0，结果放Key_Record
;----------------------------------------------------------
Key_Scan
	BCF		Key_Record,0		;置转换成功标志0
	BCF		STATUS,RP0			;体0
	BSF		ADCON0,2			;开启A/D
Wait_AD
	BTFSS	PIR1,6				;等待A/D完成
	GOTO	Wait_AD
	BTFSC	ADRES,7				;如果AD结果高4位全为0则舍弃，本次扫描没有检测到键
	GOTO	Key_Scan_Success
	BTFSC	ADRES,6
	GOTO	Key_Scan_Success
	BTFSC	ADRES,5
	GOTO	Key_Scan_Success
	BTFSC	ADRES,4
	GOTO	Key_Scan_Success
	GOTO	Key_Scan_0
Key_Scan_Success
	MOVF	ADRES,W				;A/D值到W
	ANDLW	B'11111000'			;低位 置0 舍弃，防止按键不稳干扰
	XORWF	Key_Record,W		;新旧按键值对比
	BTFSC	STATUS,Z			;测试异或结果，新旧按键不同则重置计数
	GOTO	Key_Scan_0
	INCF	Key_AD_Count		;如果相同计数+1
NO_Recount
	MOVF	ADRES,W				;更新按键记录
	ANDLW	B'11111000'			;低位 置0 舍弃，防止按键不稳干扰
	MOVWF	Key_Record			;本次AD扫描结果放Key_Record，本次扫描成功检测键值结束
	BSF		Key_Record,0		;置Key_Record,0位为1，做转换成功标志
	GOTO	Key_Scan_End
Key_Scan_0
	MOVLW	0					;重置计数
	MOVWF	Key_AD_Count
	BCF		Key_Record,0		;置转换成功标志0
Key_Scan_End
	RETURN						;函数返回
	END

