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

	MOVLW	0x42
	MOVWF	LED_Data				;����LED_Data

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

;�Ѿ����ߵ�λ���뵽LED_DataH��LED_DataL
LOOP_LED	BTFSS	LED_CS,0				;����LED_CS��LED_Dataת��w
	MOVF	LED_DataH,0
	BTFSC	LED_CS,0
	MOVF	LED_DataL,0

	CALL	TABLE1					;����w���
	MOVWF	LED_HalfDat				;���ֵ
	BCF	PORTA,2						;Ƭѡ��PORTA,2���0,ѡ��λ�����

	MOVLW	0x08					;8��ѭ��
	MOVWF	LED_OutCnt				;������LED_OutCnt
LOOP_BYTE
	BTFSS	LED_HalfDat,7			;����LED_Data.7�Ƿ�1,�������¾�
	BCF	PORTA,1						;PORTA,1��0
	BTFSC	LED_HalfDat,7			;����LED_Data.7�Ƿ�0,�������¾�
	BSF	PORTA,1						;PORTA,1��1
	RLF	LED_HalfDat,1				;����һ��LED_Data
	BSF	PORTA,0						;��һ��ʱ������PORTA,0
	BCF	PORTA,0
	DECFSZ	LED_OutCnt,1			;��һ��LED_OutCnt,��0���¾�
	GOTO	LOOP_BYTE				;����LOOP_BYTE
	BCF	TRISA,2						;���������׼����,����TRISA,2���
	BTFSC	LED_CS,0
	BSF	PORTA,2						;Ƭѡ��PORTA,2���1,ѡʮλ�����
	BTFSS	LED_CS,0
	BCF	PORTA,2						;Ƭѡ��PORTA,2���0,ѡ��λ�����


	CALL delay200ms					;��ʱ200ms
	BSF	TRISA,2						;ʱ�䵽���ջ����������Ƭѡ����
	
	COMF	LED_CS,1				;���LED_CSȡ��
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

delay200ms	;������ʱ�ӳ���.
	CLRF	Delay_Cnt0
	MOVWF	Delay_Cnt0
delayLoopA
	DECFSZ	Delay_Cnt0
	GOTO	delayLoopA
	RETURN
	END
