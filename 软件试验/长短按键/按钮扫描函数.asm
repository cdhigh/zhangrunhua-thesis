	LIST	P=16F818
	INCLUDE	P16F818.INC
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

;дADת��������
	BCF		STATUS,RP0			;��0
	MOVLW	B'01000001'			;D7 D6=01 ADת��ʱ��Ƶ��= FOSC/8
	MOVWF	ADCON0				;D5 D4 D3=000 ADת��ģ��ͨ��ѡ��RA0/AN0
	BSF		STATUS,RP0			;��1
	MOVLW	B'00001110'			;D3 D2 D1 D0 1110ѡ��RA0Ϊģ��ڡ�
	MOVWF	ADCON1				;D7=0����� ADRESL�ĵ���λ����0
	CLRF	ADRES
;----------------------------------------------------------
;�������ƣ�Key_Scan
;���������ԭ�а���ʱ��ֵKey_AD_Count
;�������������ֵ Key_Record������ʱ��ֵKey_AD_Count
;��������������ɨ�裬ɨ��һ�Σ��ܹ������ۼ���Key_AD_Count����������Ϊ0�������Key_Record
;----------------------------------------------------------
Key_Scan
	BCF		Key_Record,0		;��ת���ɹ���־0
	BCF		STATUS,RP0			;��0
	BSF		ADCON0,2			;����A/D
Wait_AD
	BTFSS	PIR1,6				;�ȴ�A/D���
	GOTO	Wait_AD
	BTFSC	ADRES,7				;���AD�����4λȫΪ0������������ɨ��û�м�⵽��
	GOTO	Key_Scan_Success
	BTFSC	ADRES,6
	GOTO	Key_Scan_Success
	BTFSC	ADRES,5
	GOTO	Key_Scan_Success
	BTFSC	ADRES,4
	GOTO	Key_Scan_Success
	GOTO	Key_Scan_0
Key_Scan_Success
	MOVF	ADRES,W				;A/Dֵ��W
	ANDLW	B'11111000'			;��λ ��0 ��������ֹ�������ȸ���
	XORWF	Key_Record,W		;�¾ɰ���ֵ�Ա�
	BTFSC	STATUS,Z			;������������¾ɰ�����ͬ�����ü���
	GOTO	Key_Scan_0
	INCF	Key_AD_Count		;�����ͬ����+1
NO_Recount
	MOVF	ADRES,W				;���°�����¼
	ANDLW	B'11111000'			;��λ ��0 ��������ֹ�������ȸ���
	MOVWF	Key_Record			;����ADɨ������Key_Record������ɨ��ɹ�����ֵ����
	BSF		Key_Record,0		;��Key_Record,0λΪ1����ת���ɹ���־
	GOTO	Key_Scan_End
Key_Scan_0
	MOVLW	0					;���ü���
	MOVWF	Key_AD_Count
	BCF		Key_Record,0		;��ת���ɹ���־0
Key_Scan_End
	RETURN						;��������
	END

