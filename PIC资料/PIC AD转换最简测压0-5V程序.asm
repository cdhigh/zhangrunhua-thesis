;PIC ADת������ѹ0-5V����


;�˳�������򵥵� ADת�� ��ʾ���� 
;ת�������C����� �ǳ�ֱ�� 
;ת����ֵADRESH��0V��0�����ȫ�� 5Vʱȫ�� 
;==============================================

include <p16f73.inc> 

ORG 0X00
NOP
START 
BCF STATUS,RP0
CLRF PORTC
MOVLW B'01000001' ;D7 D6=01 ADת��ʱ��Ƶ��= FOSC/8
MOVWF ADCON0 ;D5 D4 D3=000 ADת��ģ��ͨ��ѡ��RA0/AN0
;D2=0 AD����ɻ�δ����AD D0=0�ر�ADC
BSF STATUS,RP0 
MOVLW B'10000111' ;D7=1ȡ��������D6=0 INT�½��ش�����
MOVWF OPTION_REG ;D5=0 TOCK1ʹ���ڲ�ʱ�� D4=0 TOCK1 ����������
;D3=0����TMR0 D2 D1 D0=1 TMR0 1��256��Ƶ
CLRF TRISC
MOVLW B'00001110' ;D3 D2 D1 D0 1110ѡ��RA0Ϊģ��ڡ�
MOVWF ADCON1 ;D7=0����� ADRESL�ĵ���λ����0
BCF STATUS,RP0
MAIN
BTFSS INTCON,T0IF ;�ȴ�TMR0 ��ʱ����ж�
GOTO MAIN 
BCF INTCON,T0IF ;��TMR0 ��ʱ�����־
BSF ADCON0,GO ;����A/D
WAIT
BTFSS PIR1,ADIF ;�ȴ�A/D���
GOTO WAIT
MOVF ADRES,W ;A/Dֵ��PORTC�������ʾ
MOVWF PORTC
GOTO MAIN
END
