	LIST	P=16F716
	INCLUDE	P16F716.INC
Delay_3s_Cnt	EQU	0x1F
	ORG	0x00
	NOP
;��ʼ��
	ORG	0x00
;----------------------------------------------------------
;�������ƣ�Delay_3s
;������������ʱ3������ϵͳ���ڼ��������4��
;----------------------------------------------------------
Delay_3s
	BSF		OPTION_REG,0			;��Ƶ��256
	BSF		OPTION_REG,1			;��Ƶ��256
	BSF		OPTION_REG,2			;��Ƶ��256	
	BCF		INTCON,T0IF				;��T0IF��0
	MOVLW	0xE5					;76,ѭ��1s
	CLRF	TMR0					;����TMR0
	MOVWF	Delay_3s_Cnt
Delay_3s_1	BTFSS	INTCON,T0IF		;Timer0�����?
	GOTO	Delay_3s_1				;��!������һ��
	;�����ƿ�ʼ
	BTFSC	Delay_3s_Cnt,6			;3����,��������4��
	BCF		PORTB,1
	BTFSS	Delay_3s_Cnt,6
	BSF		PORTB,1
	;�����ƽ���
	DECFSZ	Delay_3s_Cnt,1			;��һ��Delay_3s_Cnt,��0���¾�
	GOTO	Delay_3s_1				;����Delay_3s_1
	END