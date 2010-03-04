	LIST	P=16F818
	INCLUDE	P16F818.INC
;����Ĵ���
Main_Status		EQU	0x10		;B7:��Դ״̬;B6:���ȼ̵���;B5:����������־;B4:����ֱ����־
Key_Record		EQU	0x1D		;�����������
Key_AD_Count	EQU	0x1E		;����ɨ�����ͳ��
Delay_3s_Cnt	EQU	0x1F		;3����ʱ������
Delay_Cnt0	EQU	0x20			;��ʱ������0
Delay_Cnt1	EQU	0x21			;��ʱ������1
LED_OutCnt	EQU	0x22			;���������������
LED_HalfDat	EQU	0x23			;���ֽڴ��������
LED_CS		EQU 0x24			;�����Ƭѡ
LED_DataH	EQU 0x25			;�������ʾ���ݸ�λ
LED_DataL	EQU 0x26			;�������ʾ���ݵ�λ
LED_Data	EQU 0x27			;����ʾ���������������
Volume_Data	EQU 0x28			;M62649���������ֵ
Volume_Cnt	EQU 0x29			;M62649�����λͳ��
;----------------------------------------------------------
;�������ƣ�Initial
;�汾״̬�����
;������������ʼ��IO
;----------------------------------------------------------
Initial_IO
	ORG	0
	BSF		STATUS,RP0
	MOVLW	B'00001111'			;x'x'x'��Դ��ѹ�������е㡯���̡������ѹ������
	MOVWF	TRISA
	MOVLW	B'00000000'			;��ʾDATA'��ʾCLK'��ʾCS'��ʾCS'�����ơ����ȡ���Դ���ա�
	MOVWF	TRISB
	BCF		STATUS,RP0
	CLRF	PORTA
	CLRF	PORTB
;----------------------------------------------------------
;*�������ƣ�Initial_AD
;�汾״̬������
;������������ʼ��AD
;----------------------------------------------------------
Initial_AD
	BCF		STATUS,RP0			;��0
	MOVLW	B'01000001'			;D7 D6=01 ADת��ʱ��Ƶ��= FOSC/8
	MOVWF	ADCON0				;D5 D4 D3=000 ADת��ģ��ͨ��ѡ��RA0/AN0
	BSF		STATUS,RP0			;��1
	MOVLW	B'00001110'			;D3 D2 D1 D0 1110ѡ��RA0Ϊģ��ڡ�
	MOVWF	ADCON1				;D7=0����� ADRESL�ĵ���λ����0
	CLRF	ADRES
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
;�������ƣ�Loop_Main
;������������ѭ������
;----------------------------------------------------------
Loop_Main
	
