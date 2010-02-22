	LIST	P=16F716
	INCLUDE	P16F716.INC
Delay_Cnt0	EQU	0x20
Delay_Cnt1	EQU	0x21
LED_OutCnt	EQU	0x22
LED_HalfDat	EQU	0x23
LED_CS		EQU 0x24
LED_DataH	EQU 0x25
LED_DataL	EQU 0x26
LED_Data	EQU 0x27
Volume_Data	EQU 0x28
Volume_Cnt	EQU 0x29
;��ʼ��
	ORG	0x00
	BSF	STATUS,RP0
	MOVLW	B'00000000'
	MOVWF	TRISA
	MOVLW	B'00000000'
	MOVWF	TRISB
	BCF	STATUS,RP0
	CLRF	PORTA
	CLRF	PORTB
;��ʼ�����
;----------------------------------------------------------
;�������ƣ�SET_Volume
;�������������Volume_Data
;���������
;����������M64629����
;----------------------------------------------------------
	MOVLW	0x78
SET_Volume	MOVWF	Volume_Data
	BSF		PORTB,4						;DATA:D0_RISE
	BSF		PORTB,5						;CLOCK:0_RISE
	BCF		PORTB,4						;DATA:D0_FALL
	BCF		PORTB,5						;CLOCK:0_FALL
	BSF		PORTB,5						;CLOCK:1_RISE
	BCF		PORTB,5						;CLOCK:1_FALL
	BTFSS	Volume_Data,2
	BSF		PORTB,4						;DATA:D2_RISE
	BSF		PORTB,5						;CLOCK:2_RISE
	BCF		PORTB,4						;DATA:D2_FALL
	BCF		PORTB,5						;CLOCK:2_FALL
	BTFSS	Volume_Data,3
	BSF		PORTB,4						;DATA:D3_RISE
	BSF		PORTB,5						;CLOCK:3_RISE
	BCF		PORTB,4						;DATA:D3_FALL
	BCF		PORTB,5						;CLOCK:3_FALL
	BTFSS	Volume_Data,4
	BSF		PORTB,4						;DATA:D4_RISE
	BSF		PORTB,5						;CLOCK:4_RISE
	BCF		PORTB,4						;DATA:D4_FALL
	BCF		PORTB,5						;CLOCK:4_FALL
	BTFSS	Volume_Data,5
	BSF		PORTB,4						;DATA:D5_RISE
	BSF		PORTB,5						;CLOCK:5_RISE
	BCF		PORTB,4						;DATA:D5_FALL
	BCF		PORTB,5						;CLOCK:5_FALL
	BTFSS	Volume_Data,6
	BSF		PORTB,4						;DATA:D6_RISE
	BSF		PORTB,5						;CLOCK:6_RISE
	BCF		PORTB,4						;DATA:D6_FALL
	BCF		PORTB,5						;CLOCK:6_FALL
	BTFSS	Volume_Data,0
	BSF		PORTB,4						;DATA:D7_RISE
	BSF		PORTB,5						;CLOCK:7_RISE
	BCF		PORTB,4						;DATA:D7_FALL
	BCF		PORTB,5						;CLOCK:7_FALL
	BTFSS	Volume_Data,1
	BSF		PORTB,4						;DATA:D8_RISE
	BSF		PORTB,5						;CLOCK:8_RISE
	BCF		PORTB,4						;DATA:D8_FALL
	BCF		PORTB,5						;CLOCK:8_FALL
	BSF		PORTB,4						;DATA:D9.10_RISE
	BSF		PORTB,5						;CLOCK:9_RISE
	BCF		PORTB,5						;CLOCK:9_FALL
	BSF		PORTB,5						;CLOCK:10_RISE
	BCF		PORTB,5						;CLOCK:10_FALL
	END
