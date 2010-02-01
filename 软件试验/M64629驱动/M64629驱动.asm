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
Volume_Data	EQU 0x28
Volume_Code	EQU 0x29
Volume_Cnt	EQU	0x2A
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
	MOVLW	0x78
	MOVWF	Volume_Data
Loop_Volume	MOVLW	
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
