	LIST	P=16F818
	INCLUDE	P16F818.INC

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

;��ʼ��
	ORG	0x00
	BSF		STATUS,RP0
	MOVLW	B'00001111'			;x'x'x'��Դ��ѹ�������е㡯
	MOVWF	TRISA
	MOVLW	B'00000000'
	MOVWF	TRISB
	BCF		STATUS,RP0
	CLRF	PORTA
	CLRF	PORTB
    BSF		INTCON,T0IE
    BSF		INTCON,GIE

T0_OVFL_WAIT
	BTFSS	INTCON,T0IF
	GOTO	T0_OVFL_WAIT

	END