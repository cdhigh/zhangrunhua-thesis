	LIST	P=16F716
	INCLUDE	P16F716.INC
Delay_3s_Cnt	EQU	0x1F
	ORG	0x00
	NOP
;��ʼ��
	ORG	0x00
	MOVLW	B'11000111'				;��Ƶ��256
	MOVWF	OPTION_REG

Delay_3s
	BCF	INTCON,T0IF					;��T0IF��0
	CLRF	TMR0
	MOVLW	0xFF
	MOVWF	Delay_3s_Cnt
Delay_3s_1	BTFSS	INTCON,T0IF		;Timer0�����?
	GOTO	Delay_3s_1				;��!������һ��
	DECFSZ	Delay_3s_Cnt,1			;��һ��Delay_3s_Cnt,��0���¾�
	GOTO	Delay_3s_1				;����Delay_3s_1
	RETURN							;��!�����ӳ������
	
	END