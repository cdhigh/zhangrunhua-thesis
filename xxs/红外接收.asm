list P=12F675
;����
#define	TIME_DELAY	20
#define	
;��ַ
#define	DELAY		10H

	ORG		O0H
	GOTO	START
;###########
;�жϷ������
;###########
	ORG		O4H
	;�����ж��ֳ�
	MOVWF	W_TEMP
	SWAPF	STATUS,W
	MOVWF	S_TEMP
	;�жϷ���ģʽʶ��

;###########
;������ս���
;###########
IR_RECEIVE
	;����ͷ����ʱ��
RE_LOW
	BTFSC	SIGN
	GOTO	TEST_BIT
	; ��ʱTIME_DELAY΢��
	MOVLW	TIME_DELAY
	MOVWF	DELAY
	DECFSZ	DELAY,F
	GOTO	$-1
	INCF	COUNT,F
	
	