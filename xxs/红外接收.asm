list P=12F675
;����
;ʱ�䳣��
#define	TIME_DECO	1600      ;1950
#define	TIME_DELAY	20        ;30
;��ƽʱ�����
#define COUNT   	2EH
#define DELAY		2FH
;������BYTE*BITλ����
#define     BYTE    2CH
#define     BIT     2DH
;�ж��ֳ������Ĵ�
#define     W_TEMP  2AH
#define     S_TEMP  2BH
;�����źŽ��ջ�����
#define     BUFF_0  5CH
#define     BUFF_1  5DH
#define     BUFF_2  5EH
#define     BUFF_3  5FH
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
START
;###########
;������ս���
;###########
IR_RECEIVE
	;��4�ֽ�����
	MOVLW   4
	MOVWF   BYTE
	;ÿ�ֽ�8λ
	MOVLW   8
	MOVWF   BIT
	;����ź�ͷ�͵�ƽ����ʱ�䳤��
CHECK_LOW
	;�����ź���GPIO,0
	BTFSC	GPIO,0
	GOTO	TEST_BIT	;����TEST_BIT��CHECK_BIT����bit�Ƿ���ȷ
	;��ʱTIME_DELAY΢�루1uS/1��ѭ����
	MOVLW	TIME_DELAY
	MOVWF	DELAY
	DECFSZ	DELAY,F
	GOTO	$-1
	INCF	COUNT,F
	;�ź����ʱ�䲻����+20%
	MOVLW	((TIME_DECO * 6 / 5) / 20)
	SUBWF	COUNT,W
	;ʱ���Ƿ����
    BTFSS   STATUS,C
    GOTO    CHECK_LOW
	;ʱ������뿪
    RETURN
TEST_BIT	;��CHECK_LOW����,ִ�е�CHECK_BIT��������CHECK_LOW
	;����λ����
	MOVLW   ((TIME_DECO / 5) / 20)
	SUBWF   COUNT,W
	;����ʱ���խ �뿪
	BTFSS   STATUS,C
	RETURN
	;����λʶ��
	MOVF    COUNT,W
	SUBLW   ((TIME_DECO / 2) / 20)
	;(TIME_DECO / 2 / 20) < COUNT C = 0 ����λ = 0
	;(TIME_DECO / 2 / 20) > COUNT C = 1 ����λ = 1
	;��¼һλ��λ ��λ���� ��λ�ں�
	RLF     INDF,F
CHECK_BIT	;CHECK_LOWִ�е�CHECK_BIT,Ȼ���
	;�ź��޶���Сʱ�� -20%
	MOVLW   ((TIME_DECO * 8 / 10) / 20)
	SUBWF   COUNT,W
	;ʱ���Ƿ��խ
	BTFSS   STATUS,C
	;�źŹ�խ�뿪
	RETURN
NEXT_BIT:
	;�ɹ�����һλ����
	DECFSZ  BIT,F
	GOTO    RECE_SUCCESS
	;ÿ�ֽ�8 λ
	MOVLW   8
	MOVWF   BIT
	;ָ���¸�������
	INCF    FSR,F
	;������4 ���ֽ�
	DECFSZ  BYTE,F
	GOTO    RECE_SUCCESS
RECE