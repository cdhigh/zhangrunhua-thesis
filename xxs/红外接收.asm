;----------------------------------------------------------
;��������, Ĭ��Ϊʮ����
    list P = 12f675, R = DEC
;����ͷ�ļ�           
#include <p12f675.inc>       
;��˿���ã�20M���������Ź��أ�ʹ���ϵ���ʱ���ڲ���λ��Ƿѹ��⿪
 __CONFIG _HS_OSC & _WDT_OFF & _PWRTE_ON & _MCLRE_OFF & _BODEN_ON
;----------------------------------------------------------
;ʱ�䳣��
#define	TIME_DECO	1600
#define	TIME_DELAY	20
;��ƽʱ�����
#define COUNT   	2EH
#define DELAY		2FH
;������BYTE*BITλ����
#define     BYTE    2CH
#define     BIT     2DH
;�ж��ֳ������Ĵ��ַ
#define     W_TEMP  2AH
#define     S_TEMP  2BH
;�����źŽ��ջ�����(4Byte����32��λ������)
#define     BUFF_0  5CH
#define     BUFF_1  5DH
#define     BUFF_2  5EH
#define     BUFF_3  5FH
;�������Ĳ����룬������յ��ź���
;���������һ��ֵ����ִ����Ӧ����
;���ۿ�����չ2^8-2=254��������ų�2��ȫ0ȫ1�����
#define     KEY_1  B'00000001'
#define     KEY_2  B'00000010'
#define     KEY_3  B'00000011'
#define     KEY_4  B'00000100'
#define     KEY_5  B'00000101'
#define     KEY_6  B'00000110'
#define     KEY_7  B'00000111'
;����������GPIO,0
#define     INPUT	GPIO,0
;---------------------------------------------------------------
;����ʼ�������ж�����04H��������������00H������ת��START
;---------------------------------------------------------------
	ORG		O0H
	GOTO	START
;---------------------------------------------------------------
;�жϷ������
;�ж�ʱ��PIC�Զ���04H��ʼִ�г���
;---------------------------------------------------------------
	ORG		O4H
	;�����ж��ֳ�
	MOVWF	W_TEMP
	SWAPF	STATUS,W
	MOVWF	S_TEMP
	;�жϷ���ģʽʶ��
START
;---------------------------------------------------------------
;������ս���
;����·��ʾ�⣺
;IR_RECEIVE->{RECE->CHECK_LOW(TEST_BIT->CHECK_HIGH(CHECK_BIT))->NEXT_BIT}
;����{}����ѭ��ִ�У�()��������Ӻ�����->����˳��ִ��
;----------------------------------------------------------
IR_RECEIVE
	;��4�ֽ�����
	MOVLW   4
	MOVWF   BYTE
	;ÿ�ֽ�8λ
	MOVLW   8
	MOVWF   BIT
RECE
	;����ֵ����
    CLRF   COUNT
	;����źŵ͵�ƽ����ʱ�䳤��
CHECK_LOW
	;�����ź���INPUT
	BTFSC	INPUT
	GOTO	TEST_BIT	;����TEST_BIT��CHECK_BIT����bit�Ƿ���ȷ
	;��ʱTIME_DELAY=20΢�루1uS/1��ѭ����
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
	;ʱ�����IR_RECEIVE��������
    RETURN
TEST_BIT	;��CHECK_LOW����,ִ�е�CHECK_BIT��������CHECK_LOW
	;����λ����
	MOVLW   ((TIME_DECO / 5) / 20)
	SUBWF   COUNT,W
	;����ʱ���խIR_RECEIVE��������
	BTFSS   STATUS,C
	RETURN
	;����λʶ��
	MOVF    COUNT,W
	SUBLW   ((TIME_DECO / 2) / 20)
	;(TIME_DECO / 2 / 20) < COUNT C = 0 ����λ = 0
	;(TIME_DECO / 2 / 20) > COUNT C = 1 ����λ = 1
	;��¼һλ��λ ��λ���� ��λ�ں�
	RLF     INDF,F
CHECK_HIGH
	;����źŸߵ�ƽ����ʱ�䳤��
	;�����ź���INPUT
	BTFSS   INPUT
	GOTO    CHECK_BIT
	;��ʱƥ�� ����Ϊ 20us
	MOVLW   TIME_DELAY
	MOVWF   DELAY
	DECFSZ  DELAY,F
	GOTO    $-1
	;����ֵ����
	INCF    COUNT,F
	;�ź��޶�ʱ����� +20%
	MOVLW   ((TIME_DECO * 6 / 5) / 20)
	SUBWF   COUNT,W
	;ʱ���Ƿ����
	BTFSS   STATUS,C
	GOTO    CHECK_HIGH
	;ʱ�����IR_RECEIVE��������
	RETURN
CHECK_BIT
	;�ź��޶���Сʱ�� -20%
	MOVLW   ((TIME_DECO * 8 / 10) / 20)
	SUBWF   COUNT,W
	;ʱ���Ƿ��խ
	BTFSS   STATUS,C
	;�źŹ�խ����
	RETURN	;TEST_BITִ�е��˷���
NEXT_BIT
	;�ɹ�����һλ���ݣ�BITָ��+1
	DECFSZ  BIT,F
	GOTO    RECE
	;ÿ�ֽ�8λ
	MOVLW   8
	MOVWF   BIT
	;ָ���¸�������
	INCF    FSR,F
	;BYTE������������4���ֽڽ���
	DECFSZ  BYTE,F
	GOTO    RECE
	;_________________________________
	;�����Ѿ�����4�ֽ����ݵ�BUFF_0~3
	;_________________________________
	;ǰ���ֽ�:�û�������Ա�
	COMF    BUFF_0,W
	XORWF   BUFF_1,F
	;У��ʧ���뿪
	BTFSS   STATUS,Z
	RETURN
	; ����������Ա�
    COMF    BUFF_2,W
    XORWF   BUFF_3,F
	;У��ʧ�� �뿪
	BTFSS   STATUS,Z
	RETURN
	;���⶯��1ʶ��
	MOVF    BUFF_2,W
	XORLW   KEY_1
	BTFSC   STATUS,Z
	GOTO    KEY_1_F
	;���⶯��2ʶ��
	MOVF    BUFF_2,W
	XORLW   KEY_2
	BTFSC   STATUS,Z
	GOTO    KEY_2_F
	;���⶯��3ʶ��
	MOVF   BUFF_2,W
	XORLW   KEY_3
	BTFSC   STATUS,Z
	GOTO    KEY_3_F
	;���⶯��4ʶ��
	MOVF   BUFF_2,W
	XORLW   KEY_4
	BTFSC   STATUS,Z
	GOTO    KEY_4_F
	;���⶯��5ʶ��
	MOVF   BUFF_2,W
	XORLW   KEY_5
	BTFSC   STATUS,Z
	GOTO    KEY_5_F
	;���⶯��6ʶ��
	MOVF   BUFF_2,W
	XORLW   KEY_6
	BTFSC   STATUS,Z
	GOTO    KEY_6_F
	;���⶯��7ʶ��
	MOVF   BUFF_2,W
	XORLW   KEY_7
	BTFSC   STATUS,Z
	GOTO    KEY_7_F
	;��ƥ������ȫ�����������Ч�������뿪
    RETURN
;----------------------------------------------------------
;�������ƣ�MAIN
;������������ѭ������
;----------------------------------------------------------
MAIN
;       ����ȫ������
	CLRF    INDEX
	CLRF    MARK
	CLRF    DUTY
;       Ĭ�Ͻ���ģʽ
	MOVLW   MICRO
	MOVWF   FUNC
;       ���ض�ʱ����ֵ
	MOVLW   TIME_VALUE
	MOVWF   TMR0
;       �����ж�
	BSF     INTCON,GIE
LOOP
;       ������ս���
	CALL    DECODE
;       ѭ��ִ�г���
	GOTO LOOP
    END
;----------------------------------------------------------
;�������ƣ�������ն���
;����������7�ֺ����źŶ�Ӧ7�ֶ���
;----------------------------------------------------------.
;���⶯��1ִ�У�
KEY_1_F
	MOVLW	B'00000000'
	MOVWF	OUT_DATA
	CALL	OUT_74164
	RETURN
	