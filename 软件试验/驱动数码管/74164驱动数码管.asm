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
	
;*****************�������ַ���BCD������w*****************
	MOVLW	0x1e
	MOVWF	LED_Data				;����LED_Data��W
	
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
	ADDWF   LED_Data,1				;ת�������LED_Data
	
	MOVLW	0xF0					;��0F��LED_DataH����AND��ɸѡ
	MOVWF	LED_DataH
	MOVLW	0x0F					;��0F��LED_DataL����AND��ɸѡ
	MOVWF	LED_DataL
	MOVF    LED_Data,0
	ANDWF	LED_DataH,1
	SWAPF	LED_DataH,1
	ANDWF	LED_DataL,1				;��AND�����w��׼�����ת��
	

LOOP_LED	BTFSS	LED_CS,0		;����LED_CS��LED_Dataת��w
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
	CALL delay20ms					;��ʱ200ms
	BSF	TRISA,2						;ʱ�䵽���ջ����������Ƭѡ����
	COMF	LED_CS,1				;���LED_CSȡ��
	GOTO LOOP_LED
	SLEEP
;*****************�����*****************
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
;***************���ڽ��߰��ֽڵ�BIN�뻻�����ֽڵ�ѹ��BCD��**********
BIN_HIGHHALF_BCD_TABLE
	ADDWF    PCL,1
	RETLW    B'00000000'     ;0
	RETLW    B'00010110'     ;16
	RETLW    B'00110010'     ;32
	RETLW    B'01001000'     ;48
	RETLW    B'01100100'     ;64
	RETLW    B'10000000'     ;80
	RETLW    B'10010110'     ;96
	RETLW    B'00101000'     ;128,ʧ���˰�λ
;***************���ڽ��Ͱ��ֽڵ�BIN�뻻�����ֽڵ�ѹ��BCD��**********
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

;*****************��ʱ20ms�ӳ���*****************
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
