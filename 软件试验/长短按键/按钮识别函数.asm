	LIST	P=16F818
	INCLUDE	P16F818.INC

#define		Key_Vol_Rise	1300
#define		Key_Vol_Fall	1300
#define		Key_Vol_Slient	1300
#define		Key_Power		1300
Main_Status		EQU	0x10		;B7:��Դ״̬;B6:���ȼ̵���;B5:����������־
Key_Record		EQU	0x1D
Key_AD_Count	EQU	0x1E
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
;----------------------------------------------------------
;�������ƣ�Key_Act
;���������
;���������
;����������������Ӧ������
;----------------------------------------------------------
Key_Act
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
	BCF		Main_Status,5			;����������Ϊ��
	BCF		Main_Status,4			;��ʹ������ֱ��
	CALL	Action_Vol
	GOTO	Key_OK_End

	MOVF	Key_Record,0
	XORLW	Key_Vol_Rise			;��Key_Record��Key_Vol_Rise�Ա�
	BTFSS	STATUS,Z				;���Խ���Ƿ�0
	BCF		Main_Status,4			;��ʹ������ֱ��
	BSF		Main_Status,5			;����������Ϊ��
	CALL	Action_Vol
	GOTO	Key_OK_End

	MOVF	Key_Record,0
	XORLW	Key_Vol_Slient			;��Key_Record��Key_Vol_Slient�Ա�
	BTFSS	STATUS,Z				;���Խ���Ƿ�0
	CALL	Action_Vol_Slient
Key_OK_End

	END
