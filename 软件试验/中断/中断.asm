LIST	P=16F818
INCLUDE	P16F818.INC
W_TEMP		EQU	32H
STATUS_TEM	EQU	33H
	ORG		0x00
	NOP
	GOTO	MAIN			;ת��������
	ORG 	0x04
	GOTO	INTSERVE		;ת���жϷ����ӳ���
;----------------------------------------------------------
;�������ƣ��жϷ������
;�������������ص�Դ
;----------------------------------------------------------
INTSERVE
	MOVWF	W_TEMP			;����w
	MOVF	STATUS,0		;����STATUS
	MOVWF	STATUS_TEMP
	BTFSC	PIR1,ADIF		;�ж��Ƿ�AD�ж�
	GOTO	INTSERVE_AD_END	;�����򲻽���AD�жϳ���
;AD�жϷ������
INTSERVE_AD
	CALL	Key_Scan
	MOVF	Key_AD_Count,0
	XORWF	50						;��ɨ�������50�Ա�
	BTFSS	STATUS,Z				;���Խ���Ƿ�0
	GOTO	Key_OK_End
	BTFSS	Key_Record,0			;����ɨ��ɹ�λ���Ƿ�1
	GOTO	Key_OK_End				;ɨ��ʧ������Key_OK_End
	;��ⰴ���ɹ����������
	MOVF	Key_Record,0
	XORLW	Key_Power				;��Key_Record��Key_Power�Ա�
	BTFSS	STATUS,Z				;���Խ���Ƿ�0
	CALL	Action_Power_OnOff
	GOTO	Key_OK_End

	MOVF	Key_Record,0
	XORLW	Key_Vol_Fall			;��Key_Record��Key_Vol_Fall�Ա�
	BTFSS	STATUS,Z				;���Խ���Ƿ�0
	CALL	Action_Vol_Fall
	GOTO	Key_OK_End

	MOVF	Key_Record,0
	XORLW	Key_Vol_Rise			;��Key_Record��Key_Vol_Rise�Ա�
	BTFSS	STATUS,Z				;���Խ���Ƿ�0
	CALL	Action_Vol_Rise
	GOTO	Key_OK_End

	MOVF	Key_Record,0
	XORLW	Key_Vol_Slient			;��Key_Record��Key_Vol_Slient�Ա�
	BTFSS	STATUS,Z				;���Խ���Ƿ�0
	CALL	Action_Vol_Slient
Key_OK_End

INTSERVE_AD_END

RE	MOVF	STATUS_TEM       ;�жϷ���
	MOVWF	STATUS
	SWAPF	W_TEMP,1
	SWAPF	W_TEMP,0
	RETFIE
	BCF		PIR1,ADIF		;��������ж�����Ĵ���
MAIN
;��ʼ��
	ORG	0x00
	BSF		STATUS,RP0
	MOVLW	B'00001111'
	MOVWF	TRISA
	MOVLW	B'00000000'
	MOVWF	TRISB
	BCF		STATUS,RP0
	CLRF	PORTA
	CLRF	PORTB
;дADת��������
	BSF		STATUS,RP0			;��1
	MOVLW	B'00001110'			;D3 D2 D1 D0 1110ѡ��RA0Ϊģ��ڡ�
	MOVWF	ADCON1				;D7=0����� ADRESL�ĵ���λ����0
	BCF		STATUS,RP0			;��0
	MOVLW	B'01000001'			;D7 D6=01 ADת��ʱ��Ƶ��= FOSC/8
	MOVWF	ADCON0				;D5 D4 D3=000 ADת��ģ��ͨ��ѡ��RA0/AN0