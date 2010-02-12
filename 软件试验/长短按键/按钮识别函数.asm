	LIST	P=16F716
	INCLUDE	P16F716.INC
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
;�������ƣ�KEY_SCAN
;�����������
;�������������ֵ Key_Record
;��������������ɨ�裬ÿ500usɨ��һ�Σ��ܹ�ɨ��50��
;----------------------------------------------------------
Key_Scan
	CALL	Delay_500us			;��ʱ500usɨ��
	MOVLW	50					;ɨ��50�μ���
	MOVWF	Key_AD_Count
	BCF		STATUS,RP0			;��0
	BSF		ADCON0,2			;����A/D
Wait_AD
	BTFSS	PIR1,6				;�ȴ�A/D���
	GOTO	Wait_AD
	MOVF	ADRES,W				;A/Dֵ��W
	XORWF	Key_Record,W		;�¾ɰ���ֵ�Ա�
	BTFSC	STATUS,Z			;���������
	GOTO	NO_Recount			;�����ͬ�����ü���
	MOVLW	50					;���ü���
	MOVWF	Key_AD_Count
NO_Recount
	MOVF	ADRES,W				;���°�����¼
	MOVWF	Key_Record
	RETURN						;��������

Delay_500us:
	MOVLW	((500 - 2) / 3)
	MOVWF	Wait_500_Cnt
Wait_500
	DECFSZ	Wait_500_Cnt,1
	GOTO	Wait_500
	RETURN

	END

