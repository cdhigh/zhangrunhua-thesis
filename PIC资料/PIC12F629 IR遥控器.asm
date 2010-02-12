;----------------------------------------------------------
;��Ŀ���ƣ�PIC12F629 IR
;
;��Ŀ��飺��ΰ�ң����������Ŀ����Ϊ����߱���̳����������
;��ġ����þ��д����Ե�PIC12F629��Ƭ������ͼ�����ó�ѧ���ʷ�
;��⣬PIC��Ƭ���ľ��򣬵͹��ġ�
;
;ʵ�ֹ��ܣ�PIC12F629������4MHz@3V��ʵ��38KHz�����ز��źţ���
;�����ݵ��ơ���������ɨ�裬֧�ֶ�·�������¡��������£��ſ�
;���� 20 * 500u ��������ÿ����Ч������������������ݱ��롣
;�ڷ��ͺ󣬴���״̬��PIC12F629����˯�ߡ�ʵ����͹��Ĵ�����
;
;��Ŀ���ߣ����ε� (PIC��Ƭ����ѧ��̳+��̼�������)����
;�������ڣ�2009��4��28�� �� 2009��5��5��
;����汾��V 1.01
;�޸��ϰ汾Դ�����еĴ�����
;����ƽ̨��MPASMWIN v5.30.01, mplink v4.30.01 MPLAB V8.30
;----------------------------------------------------------

;��������, Ĭ��Ϊʮ����
        list P = 12f629, R = DEC

;����ͷ�ļ�
		#include <p12f629.inc>

;��˿���ã�4M ���������Ź��أ�ʹ���ϵ���ʱ���ڲ���λ��Ƿѹ����
 __CONFIG _HS_OSC & _WDT_OFF & _PWRTE_ON & _MCLRE_OFF & _BODEN_OFF

;----------------------------------------------------------
;��λ����
#define	    LED_IR	GPIO,0

;ʱ�䳣��
#define     BIT_T   1950
#define     BIT_1   1300
#define     BIT_0   650

;ɨ�����
#define     SCAN    20

;4 �����
#define     GROUP   4

;�����ſ�
#define     KEY_UP  00001110B

;��ҳ����
#define     BANK0   BCF STATUS,RP0
#define     BANK1   BSF STATUS,RP0

;��������
#define     NOP1    NOP
#define     NOP2    GOTO $+1

;�ڴ����
#define     BIT_CNT 20H
#define     TEMP    21H
#define     TEST    22H
#define     COUNT1  23H
#define     COUNT2  24H
#define     COUNT3  25H
#define     COUNT4  26H

;������־
#define     MARK    27H,0

;������¼
#define     VALUE   28H
#define     RECORD  29H

;������
#define     BUFF_0  5CH
#define     BUFF_1  5DH
#define     BUFF_2  5EH
#define     BUFF_3  5FH

;----------------------------------------------------------
		ORG		0000H

        GOTO    START

;----------------------------------------------------------
;�������ƣ�START
;�����������
;�����������
;�����������ϵ��ʼ��
;----------------------------------------------------------
        ORG     00006H
START:
		BANK0

;       GPIO ȫ������
        MOVLW   00000000B
        MOVWF   GPIO

;       ��ģ��Ƚ���
		MOVLW 	00000111B
		MOVWF 	CMCON

;       ʹ�ܵ�ƽ�仯����
        MOVLW   00001000B
        MOVWF   INTCON

        BANK1
;                   |---- KEY2   ��������
;                   ||--- KEY1   ��������
;                   |||-- KEY0   ��������
;                   ||||- LED_IR �������
        MOVLW   00001110B
        MOVWF   TRISIO

;       ����ȫ����ֹ
        MOVLW   10000000B
        MOVWF   OPTION_REG

;       GPIO ʹ�ܵ�ƽ�仯
        MOVLW   00001110B
        MOVWF   IOC

		BANK0

        GOTO    MAIN

;----------------------------------------------------------
;�������ƣ�PULSE
;������������������ BIT_CNT
;�����������
;���������������ز��źţ�Ƶ�� 1 / 26us = 38.46KHz
;----------------------------------------------------------
PULSE:
;       LED_IR = 1 ��ʱ  8us
        BSF		LED_IR
        NOP1
        NOP2
        NOP2
        NOP2

;       LED_IR = 0 ��ʱ 18us
		BCF		LED_IR
        NOP2
        NOP2
        NOP2
        NOP2
        NOP2
        NOP2
        NOP2

;       ѭ�����͵�����
        DECFSZ  BIT_CNT,F
        GOTO    PULSE

;       ��������
        RETURN

;----------------------------------------------------------
;�������ƣ�TX_SYNC
;�����������
;�����������
;��������������ͬ�����ز��ź�
;----------------------------------------------------------
TX_SYNC:
;       ���� 9000us ͬ�����ز��ź�
        MOVLW   2
        MOVWF   COUNT1

        MOVLW   (9000 / 26 / 2)
        MOVWF   COUNT2
SYNC:
;       LED_IR = 1 ��ʱ  8us
        BSF		LED_IR
        NOP1
        NOP2
        NOP2
        NOP2
HALF:
;       LED_IR = 0 ��ʱ 18us
		BCF		LED_IR
        NOP2
        NOP2
        NOP2
        NOP2
        NOP2
        NOP2
        NOP2

;       ��ѭ�����͵�����
        DECFSZ  COUNT2,F
        GOTO    SYNC

;       ʱ�䲹�� 18us
        NOP1
        BSF		LED_IR

;       ʱ�䲹�� 8us
        NOP2

;       ���¼�����ѭ�����͵�����
        MOVLW   (9000 / 26 / 2)
        MOVWF   COUNT2

;       ��ѭ�����͵�����
        DECFSZ  COUNT1,F
        GOTO    HALF

;       ʱ�䲹�� 8us
        NOP1
        BCF     LED_IR

;       ��ʱ 4500us, ��ѭ������
        MOVLW   (4500 / 500)
        MOVWF   COUNT1
DELAY1:
;       ��ѭ������
        MOVLW   ((500 - 2) / 3)
        MOVWF   COUNT2

        DECFSZ  COUNT2,F
        GOTO    $-1

        DECFSZ  COUNT1,F
        GOTO    DELAY1

;       ��������
        RETURN

;----------------------------------------------------------
;�������ƣ�TX_BIT0
;�����������
;�����������
;��������������λ'0'�ز��ź�
;----------------------------------------------------------
TX_BIT0:
;       λ'0' ���峣��
        MOVLW   ((BIT_T - BIT_0) / 26)
        MOVWF   BIT_CNT

;       �����ز��ź�
        CALL    PULSE

;       ��ʱ 650us
        MOVLW   ((BIT_0 - 2) / 3)
        MOVWF   COUNT1

        DECFSZ  COUNT1,F
        GOTO    $-1

;       ��������
        RETURN

;----------------------------------------------------------
;�������ƣ�TX_BIT1
;�����������
;�����������
;��������������λ'1'�ز��ź�
;----------------------------------------------------------
TX_BIT1:
;       λ'1' ���峣��
        MOVLW   ((BIT_T - BIT_1) / 26)
        MOVWF   BIT_CNT

;       �����ز��ź�
        CALL    PULSE

;       ��ʱ 1300us
        MOVLW   ((BIT_1 - 2) / 6)
        MOVWF   COUNT1

        NOP1
        NOP2
        DECFSZ  COUNT1,F
        GOTO    $-3

;       ��������
        RETURN

;----------------------------------------------------------
;�������ƣ�TX_BYTE
;����������ȴ����͵����� TEMP
;�����������
;��������������һ�ֽ�����
;----------------------------------------------------------
TX_BYTE:
;       ��������λ, ��λ����
        MOVLW   B'10000000'
        MOVWF   TEST
TEST_BIT:
;       ����һλ����
        ANDWF   TEMP,W

;       ����λ'1'
        BTFSS   STATUS,Z
        CALL    TX_BIT1

;       ����λ'0'
        BTFSC   STATUS,Z
        CALL    TX_BIT0

;       ������������һλ
        BCF     STATUS,C
        RRF     TEST,F

;       �Ƿ��Ѿ�����8λ
        MOVF    TEST,W
        BTFSS   STATUS,Z
        GOTO    TEST_BIT

;       ��������
        RETURN

;----------------------------------------------------------
;�������ƣ�TX_CODING
;�������������ֵ VALUE
;�����������
;���������������������ݱ���
;----------------------------------------------------------
TX_CODING:
;       �����û�����
        MOVLW   'I'
        MOVWF   BUFF_0

;       �����û�����
        COMF    BUFF_0,W
        MOVWF   BUFF_1

;       �������ݱ���
        MOVF    VALUE,W
        MOVWF   BUFF_2

;       �������ݷ���
        COMF    BUFF_2,W
        MOVWF   BUFF_3

;       ����4���������
        MOVLW   GROUP
        MOVWF   COUNT3
CODING:
;       ���ͻ���������, ��4�ֽ�
        MOVLW   4
        MOVWF   COUNT4

;       ���ػ�������ַ
        MOVLW   BUFF_0
        MOVWF   FSR

;       ����ͬ������
        CALL    TX_SYNC
TX_DATA:
;       ���������͵�����
        MOVF    INDF,W
        MOVWF   TEMP

;       ��������ַ��1
        INCF    FSR,F

;       ����һ�ֽ�����
        CALL    TX_BYTE

;       һ������4�ֽ�����
        DECFSZ  COUNT4,F
        GOTO    TX_DATA

;       һ������4���������
        DECFSZ  COUNT3,F
        GOTO    CODING

;       ��������
        RETURN

;----------------------------------------------------------
;�������ƣ�DELAY_500US
;�����������
;�����������
;������������ʱ500us
;----------------------------------------------------------
DELAY_500US:
;       ����500us ��ʱ����
        MOVLW   ((500 - 2) / 3)
        MOVWF   COUNT1

        DECFSZ  COUNT1,F
        GOTO    $-1

;       ��������
        RETURN

;----------------------------------------------------------
;�������ƣ�KEY_SCAN
;�����������
;�������������ֵ VALUE
;��������������ɨ��
;----------------------------------------------------------
KEY_SCAN:
;       ���ذ���ɨ�賣��
        MOVLW   SCAN
        MOVWF   COUNT2

KEY_READ:
;       500us ��ȡ����һ��
        CALL    DELAY_500US

;       ��ȡ����
        MOVLW   KEY_UP
        ANDWF   GPIO,W
        MOVWF   VALUE

;       �¾ɰ���ֵ�Ա�
        XORWF   RECORD,W
        BTFSC   STATUS,Z

;       ��¼��ͬ ˳��ִ��
        GOTO    $+3

;       ��¼��ͬ ���¼���
        MOVLW   SCAN
        MOVWF   COUNT2

;       ���°�����¼
        MOVF    VALUE,W
        MOVWF   RECORD

;       ɨ�谴������
        DECFSZ  COUNT2,F
        GOTO    KEY_READ

;       ��������
        RETURN

;----------------------------------------------------------
;�������ƣ�KEY_COM
;�������������ֵ VALUE
;�����������
;��������������ʶ����
;----------------------------------------------------------
KEY_COM:
;       �����ſ�ʶ��
        MOVLW   KEY_UP
        XORWF   VALUE,W

        BTFSS   STATUS,Z
        GOTO    $+3

;       �����ſ� ���־ �뿪
        BCF     MARK
        RETURN

;       �������� �����뿪
        BTFSC   MARK
        RETURN

;       ִֻ��һ�� �ñ�־
        BSF     MARK

;       ���������ı�������
        CALL    TX_CODING

;       ��ȡ����ֵ
        MOVLW   KEY_UP
        ANDWF   GPIO,W
        MOVWF   VALUE

;       �����ſ����
        MOVLW   KEY_UP
        XORWF   VALUE,W

;       �����ѷſ� ���ʾ
        BTFSC   STATUS,Z
        BCF     MARK

;       ��������
        RETURN

;----------------------------------------------------------
;�������ƣ�MAIN
;�����������
;�����������
;������������ѭ������
;----------------------------------------------------------
MAIN:
;       �尴��������־
        BCF     MARK
LOOP:
;       ���ѱ�ʾ����
        MOVF    GPIO,W
        BCF     INTCON,GPIF

;       ϵͳ����˯��
        SLEEP

;       ��������
        NOP1

;       ִ�а���ɨ��
        CALL    KEY_SCAN

;       ����ʶ����
        CALL    KEY_COM

;       ѭ��ִ�г���
        GOTO	LOOP

;----------------------------------------------------------
		END
