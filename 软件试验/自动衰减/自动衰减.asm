	LIST	P=16F818
	INCLUDE	P16F818.INC
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
;�������ƣ�Auto_Vol
;���������
;���������
;�����������Զ�����������
;----------------------------------------------------------
Auto_Vol
	CALL	Read_Curr_Vol
	
	END
