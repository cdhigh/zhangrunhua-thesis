	LIST	P=16F818
	INCLUDE	P16F818.INC
Main_Status		EQU	0x10		;B7:��Դ״̬;B6:���ȼ̵���;B5:����������־;B4:����ֱ����־
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
	BTFSC	Main_Status,7
	BSF		PORTB,1					;B1��Դ���ƽӵ�
	BTFSS	Main_Status,7
	BCF		PORTB,1					;B1��Դ���ƽӵ�
	MOVLW	B'10000000'				;��Main_Status���λȡ��
	XORWF	Main_Status,1
	RETURN
;----------------------------------------------------------
;�������ƣ�Action_Vol
;�������������Volume_Data;Main_Status,5:����������־;Main_Status,6:����ֱ����־
;���������
;������������������
;----------------------------------------------------------
Action_Vol
	;����ֱ��
	BTFSC	Main_Status,4			;�ж��Ƿ�����ֱ�ӵ���
	GOTO	Vol_Set_End
	;��������
	BTFSC	Main_Status,5			;�ж���������
	INCF	Volume_Data,1			;Volume_Dataֵ�Լ�1
	BTFSS	Main_Status,5			;�ж���������
	DECF	Volume_Data,1			;Volume_Dataֵ�Լ�1
Vol_Set_End
	CALL	SET_Volume				;����SET_Volume����M64629
	MOVF	Volume_Data				;����ǰ����ֵ���Ƶ�
	MOVWF	LED_Data
	CALL	LED_Display				;��ʾ����
	RETURN
	END
