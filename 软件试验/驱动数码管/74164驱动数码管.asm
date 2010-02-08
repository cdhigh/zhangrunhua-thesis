	LIST	P=16F716
	INCLUDE	P16F716.INC
;	__CONFIG _WDT_OFF & _PWRTE_ON & _MCLRE_OFF & _BODEN_OFF
Delay_Cnt0	EQU	0x20
Delay_Cnt1	EQU	0x21
LED_OutCnt	EQU	0x22
LED_HalfDat	EQU	0x23
LED_CS		EQU 0x24
LED_DataH	EQU 0x25
LED_DataL	EQU 0x26
LED_Data	EQU 0x27
;初始化
	ORG	0x00
	BSF	STATUS,RP0
	MOVLW	B'00000000'
	MOVWF	TRISA
	MOVLW	B'00000000'
	MOVWF	TRISB
	BCF	STATUS,RP0
	CLRF	PORTA
	CLRF	PORTB
;初始化完毕
	
;*****************输入数字分离BCD码结果到w*****************
	MOVLW	0x1e
	MOVWF	LED_Data				;输入LED_Data到W
	
	MOVF    LED_Data,0
	MOVWF   LED_HalfDat
	SWAPF   LED_Data,0
	ANDLW   0X0F
	CALL    BIN_HIGHHALF_BCD_TABLE
	MOVWF   LED_Data
	MOVF    LED_HalfDat,0
	ANDLW   0X0F
	CALL    BIN_LOWHALF_BCD_TABLE
	ADDWF   LED_Data,0
	MOVWF   LED_HalfDat
	ANDLW   0XF0
	MOVWF   LED_Data
	MOVF    LED_HalfDat,0
	ANDLW   0X0F
	CALL    BIN_LOWHALF_BCD_TABLE
	ADDWF   LED_Data,1				;转换结果到LED_Data
	
	MOVLW	0xF0					;将0F送LED_DataH，等AND做筛选
	MOVWF	LED_DataH
	MOVLW	0x0F					;将0F送LED_DataL，等AND做筛选
	MOVWF	LED_DataL
	MOVF    LED_Data,0
	ANDWF	LED_DataH,1
	SWAPF	LED_DataH,1
	ANDWF	LED_DataL,1				;将AND结果放w，准备查表转换
	

LOOP_LED	BTFSS	LED_CS,0		;根据LED_CS将LED_Data转到w
	MOVF	LED_DataH,0
	BTFSC	LED_CS,0
	MOVF	LED_DataL,0
	CALL	TABLE1					;按照w查表
	MOVWF	LED_HalfDat				;输出值
	BCF	PORTA,2						;片选脚PORTA,2输出0,选个位数码管
	MOVLW	0x08					;8次循环
	MOVWF	LED_OutCnt				;次数存LED_OutCnt
LOOP_BYTE
	BTFSS	LED_HalfDat,7			;测试LED_Data.7是否1,是则跳下句
	BCF	PORTA,1						;PORTA,1置0
	BTFSC	LED_HalfDat,7			;测试LED_Data.7是否0,是则跳下句
	BSF	PORTA,1						;PORTA,1置1
	RLF	LED_HalfDat,1				;左移一次LED_Data
	BSF	PORTA,0						;给一个时钟脉冲PORTA,0
	BCF	PORTA,0
	DECFSZ	LED_OutCnt,1			;减一次LED_OutCnt,到0跳下句
	GOTO	LOOP_BYTE				;继续LOOP_BYTE
	BCF	TRISA,2						;输出数字已准备好,设置TRISA,2输出
	BTFSC	LED_CS,0
	BSF	PORTA,2						;片选脚PORTA,2输出1,选十位数码管
	BTFSS	LED_CS,0
	BCF	PORTA,2						;片选脚PORTA,2输出0,选个位数码管
	CALL delay20ms					;延时200ms
	BSF	TRISA,2						;时间到，收回输出，设置片选高阻
	COMF	LED_CS,1				;如果LED_CS取反
	GOTO LOOP_LED
	SLEEP
;*****************段码表*****************
TABLE1	ADDWF	PCL,1
	RETLW        0X40;
	RETLW        0X79;
	RETLW        0X24;
	RETLW        0X30;
	RETLW        0X19;
	RETLW        0X12;
	RETLW        0X02;
	RETLW        0X58;
	RETLW        0X00;
	RETLW        0X10;
;***************用于将高半字节的BIN码换成整字节的压缩BCD码**********
BIN_HIGHHALF_BCD_TABLE
	ADDWF    PCL,1
	RETLW    B'00000000'     ;0
	RETLW    B'00010110'     ;16
	RETLW    B'00110010'     ;32
	RETLW    B'01001000'     ;48
	RETLW    B'01100100'     ;64
	RETLW    B'10000000'     ;80
	RETLW    B'10010110'     ;96
	RETLW    B'00101000'     ;128,失掉了百位
;***************用于将低半字节的BIN码换成整字节的压缩BCD码**********
BIN_LOWHALF_BCD_TABLE
	ADDWF    PCL,1
	RETLW    B'00000000'     ;0
	RETLW    B'00000001'     ;1
	RETLW    B'00000010'     ;2
	RETLW    B'00000011'     ;3
	RETLW    B'00000100'     ;4
	RETLW    B'00000101'     ;5
	RETLW    B'00000110'     ;6
	RETLW    B'00000111'     ;7
	RETLW    B'00001000'     ;8
	RETLW    B'00001001'     ;9
	RETLW    B'00010000'     ;A
	RETLW    B'00010001'     ;B
	RETLW    B'00010010'     ;C
	RETLW    B'00010011'     ;D
	RETLW    B'00010100'     ;E
	RETLW    B'00010101'     ;F

;*****************延时20ms子程序*****************
delay20ms
	MOVLW	0x12
	MOVWF	Delay_Cnt0
delayLoopA	CLRF	Delay_Cnt1
delayLoopB	DECFSZ	Delay_Cnt1
	GOTO	delayLoopB
	DECFSZ	Delay_Cnt0
	GOTO	delayLoopA
	RETURN
	END
