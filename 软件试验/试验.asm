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

	MOVLW	0x42
	MOVWF	LED_Data				;输入LED_Data

	MOVLW	0x0F
	MOVWF	LED_DataL
	MOVLW	0xF0
	MOVWF	LED_DataH
	
	MOVF	LED_Data,0
	ANDWF	LED_DataH,1
	ANDWF	LED_DataL,1
	RRF		LED_DataH,1
	RRF		LED_DataH,1
	RRF		LED_DataH,1
	RRF		LED_DataH,1

;已经将高低位分离到LED_DataH，LED_DataL
LOOP_LED	BTFSS	LED_CS,0				;根据LED_CS将LED_Data转到w
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


	CALL delay200ms					;延时200ms
	BSF	TRISA,2						;时间到，收回输出，设置片选高阻
	
	COMF	LED_CS,1				;如果LED_CS取反
	GOTO LOOP_LED
	SLEEP
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

delay200ms	;调用延时子程序.
	CLRF	Delay_Cnt0
	MOVWF	Delay_Cnt0
delayLoopA
	DECFSZ	Delay_Cnt0
	GOTO	delayLoopA
	RETURN
	END
