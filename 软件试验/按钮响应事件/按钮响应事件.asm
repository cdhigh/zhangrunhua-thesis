	LIST	P=16F818
	INCLUDE	P16F818.INC
Main_Status	EQU	0x10			;B7:��Դ״̬;B6:���ȼ̵���
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
;�������ƣ�Action_Power_OnOff
;���������
;���������
;�������������ص�Դ
;----------------------------------------------------------
Action_Power_OnOff
	BTFSS	Main_Status,7
	BSF		PORTB,1					;B1��Դ���ƽӵ�
	BTFSC	Main_Status,7
	BCF		PORTB,1					;B1��Դ���ƽӵ�
	MOVLW	B'10000000'				;��Main_Status���λȡ��
	XORWF	Main_Status,1
	RETURN
	END
