	LIST	P=16F818
	INCLUDE	P16F818.INC
;����Ĵ���
Main_Status		EQU	0x10		;B7:��Դ״̬;B6:���ȼ̵���;B5:����������־;B4:����ֱ����־
Key_Record		EQU	0x1D		;�����������
Key_AD_Count	EQU	0x1E		;����ɨ�����ͳ��
Delay_3s_Cnt	EQU	0x1F		;3����ʱ������
Delay_Cnt0		EQU	0x20		;��ʱ������0
Delay_Cnt1		EQU	0x21		;��ʱ������1
LED_OutCnt		EQU	0x22		;���������������
LED_HalfDat		EQU	0x23		;���ֽڴ��������
LED_CS			EQU 0x24		;�����Ƭѡ
LED_DataH		EQU 0x25		;�������ʾ���ݸ�λ
LED_DataL		EQU 0x26		;�������ʾ���ݵ�λ
LED_Data		EQU 0x27		;����ʾ���������������
Volume_Data		EQU 0x28		;M62649���������ֵ
Volume_Cnt		EQU 0x29		;M62649�����λͳ��
;----------------------------------------------------------
;�������ƣ�START
;�汾״̬�����
;�����������������
;----------------------------------------------------------
START
	ORG		0x00
	NOP
	GOTO	MAIN				;ת��������
	ORG 	0x04
	GOTO	INT_SERVER			;ת���жϷ����ӳ���
;----------------------------------------------------------
;*�������ƣ�Initial_IO_AD_INT
;�汾״̬�����
;������������ʼ��IO��AD��INT
;----------------------------------------------------------
Initial_IO_AD
;IO
	BSF		STATUS,RP0
	MOVLW	B'00001111'			;x'x'x'��Դ��ѹ�������е㡯���̡������ѹ������
	MOVWF	TRISA
	MOVLW	B'00000000'			;��ʾDATA'��ʾCLK'��ʾCS'��ʾCS'�����ơ����ȡ���Դ���ա�
	MOVWF	TRISB
	BCF		STATUS,RP0
	CLRF	PORTA
	CLRF	PORTB
;INT
	MOVLW	B'11001000'			;�����жϺ�RB�ж�ʹ��
	MOVWF	INTCON
	MOVLW	B'01000000'			;AD�ж�ʹ��
	MOVWF	PIE1
;----------------------------------------------------------
;�������ƣ�Delay_3s
;�汾״̬�����
;������������ʱ3������ϵͳ���ڼ��������4��
;----------------------------------------------------------
Delay_3s
	BSF		OPTION_REG,0		;��Ƶ��256
	BSF		OPTION_REG,1		;��Ƶ��256
	BSF		OPTION_REG,2		;��Ƶ��256
	BCF		INTCON,T0IF			;��T0IF��0
	MOVLW	0xE5				;76,ѭ��1s
	CLRF	TMR0				;����TMR0
	MOVWF	Delay_3s_Cnt
Delay_3s_1
	BTFSS	INTCON,T0IF	;Timer0�����?
	GOTO	Delay_3s_1			;��!������һ��
	;�����ƿ�ʼ
	BTFSC	Delay_3s_Cnt,6		;3����,��������4��
	BCF		PORTB,1
	BTFSS	Delay_3s_Cnt,6
	BSF		PORTB,1
	;�����ƽ���
	DECFSZ	Delay_3s_Cnt,1		;��һ��Delay_3s_Cnt,��0���¾�
	GOTO	Delay_3s_1			;����Delay_3s_1
;----------------------------------------------------------
;�������ƣ�Set_Init_Vol
;�汾״̬�����
;������������ȡEEPROM�ϴ�����ֵ���ݣ�������������
;----------------------------------------------------------
	MOVLW	0x20				;�����ϴιػ������洢EEPROM��ַ
	CALL	Read_EEPROM			;�����ַ��w�����������w
	MOVWF	Volume_Cnt			;������������
	MOVLW	0					;
	MOVWF	Volume_Data			;����������ʼֵ
Set_Init_Vol
	CALL	SET_Volume			;������������
	INCF	Volume_Data,1		;Volume_Data��һ
	MOVF	Volume_Data,0		;Volume_Data����w
	XORWF	Volume_Cnt			;w�е�Volume_Data��Volume_Cnt�Ƚ�
	BTFSS	STATUS,Z			;���Խ���Ƿ�0
	GOTO	Set_Init_Vol		;Volume_Data��Volume_Cnt��ͬ����ѭ��
;----------------------------------------------------------
;�������ƣ�MAIN
;����������������
;----------------------------------------------------------
MAIN
;�Զ���������
	CALL	Read_Now_Vol		;��ȡ��ǰ������VOL_NOW
	MOVLW	0					;���������¼VOL_MAX��0
	MOVWF	VOL_MAX				;
	MOVLW	0xF0				;���ֵVOL_LIM��w
	MOVWF	VOL_LIM				;
	SUBWF	Volume_Data,1
	BTFSC	STATUS,Z
	GOTO	NOW_MORETHAN_LIMIT	;���
	BTFSS	STATUS,C
	GOTO	NOW_MORETHAN_LIMIT	;��ǰ�������ڼ���
	BTFSC	STATUS,C
	GOTO	NOW_LESSTHAN_LIMIT	;��ǰ����С�ڼ���
NOW_MORETHAN_LIMIT
	RRF		Volume_Data			;��������2(ѭ������һλ)
	BCF		Volume_Data,7		;��λ��0
	CALL	SET_VOL				;Ӧ������
	CALL	WAIT_500ms			;�ȴ�0.5s
	CALL	Read_Now_Vol		;��ȡ��ǰ������VOL_NOW
	MOVLW	VOL_LIM_2			;�����м�ֵVOL_LIM_2��w
	SUBWF	Volume_Data,1		;��ǰ�����뼫�ޱȽ�
	BTFSC	STATUS,Z
	GOTO	Auto_Vol			;��ǰ�����뼫�����
	BTFSS	STATUS,C
	GOTO	Auto_Vol			;��ǰ�������ڼ���
	CALL	WAIT_500ms			;�ȴ�0.5s
	MOVF	VOL_MAX				;/ʣ���������ǰ����С�ڼ���
	MOVWF	Volume_Data			;����������Ϊԭֵ
	CALL	SET_VOL				;Ӧ������
;----------------------------------------------------------
;�������ƣ�LED_Display
;�������������Volume_Data
;���������
;����������������ʾ
;----------------------------------------------------------
LED_Display
;�������ַ���BCD������w
	MOVLW	0x1E
	MOVWF	LED_Data				;����LED_Data��W
	MOVF	LED_Data,0
	MOVWF	LED_HalfDat
	SWAPF	LED_Data,0
	ANDLW	0X0F
	CALL	BIN_HIGHHALF_BCD_TABLE
	MOVWF	LED_Data
	MOVF	LED_HalfDat,0
	ANDLW	0X0F
	CALL	BIN_LOWHALF_BCD_TABLE
	ADDWF	LED_Data,0
	MOVWF	LED_HalfDat
	ANDLW	0XF0
	MOVWF	LED_Data
	MOVF	LED_HalfDat,0
	ANDLW	0X0F
	CALL	BIN_LOWHALF_BCD_TABLE
	ADDWF	LED_Data,1				;ת�������LED_Data
	MOVLW	0xF0					;��0F��LED_DataH����AND��ɸѡ
	MOVWF	LED_DataH
	MOVLW	0x0F					;��0F��LED_DataL����AND��ɸѡ
	MOVWF	LED_DataL
	MOVF	LED_Data,0
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
	RETLW	0X40;
	RETLW	0X79;
	RETLW	0X24;
	RETLW	0X30;
	RETLW	0X19;
	RETLW	0X12;
	RETLW	0X02;
	RETLW	0X58;
	RETLW	0X00;
	RETLW	0X10;
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
	GOTO	END_MAIN
	
delay20ms
	MOVLW	0x12
	MOVWF	Delay_Cnt0
delayLoopA	CLRF	Delay_Cnt1
delayLoopB	DECFSZ	Delay_Cnt1
	GOTO	delayLoopB
	DECFSZ	Delay_Cnt0
	GOTO	delayLoopA
	RETURN
	END_MAIN
	END
