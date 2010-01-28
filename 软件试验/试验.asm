	LIST	P=16F716
	INCLUDE	P16F716.INC
;	__CONFIG _WDT_OFF & _PWRTE_ON & _MCLRE_OFF & _BODEN_OFF
Delay_Cnt0	EQU	0x20
Delay_Cnt1	EQU	0x21
LED_OutCnt	EQU	0x22
LED_OutDat	EQU	0x23
LED_CS		EQU 0x24
LED_DataH	EQU 0x25
LED_DataL	EQU 0x26

;初始化
	ORG	0x00
	BSF	STATUS,RP0
	MOVLW	B'00000000'
	MOVWF	TRISA
	MOVLW	B'00000000'
	MOVWF	TRISB
	BCF	STATUS,RP0
	CLRF	PORTA
	CLRF	PORTB
;初始化完毕
	MOVLW	0x01					;输入
	CALL	TABLE1					;查表
	MOVWF	LED_OutDat				;输出值
;查表完毕,需要转换为ASCII
	MOVLW	0x01					;8次循环
	MOVWF	LED_CS					;次数存LED_OutCnt
LOOP_LED
	MOVLW	0x08					;8次循环
	MOVWF	LED_OutCnt				;次数存LED_OutCnt
LOOP_BYTE
	BTFSS	LED_OutDat,7			;测试LED_OutDat.7是否1,是则跳下句
	BCF	PORTA,1						;PORTA,1置0
	BTFSC	LED_OutDat,7			;测试LED_OutDat.7是否0,是则跳下句
	BSF	PORTA,1						;PORTA,1置1
	RLF	LED_OutDat,1				;左移一次LED_OutDat
	BSF	PORTA,0						;给一个时钟脉冲PORTA,0
	BCF	PORTA,0
	DECFSZ	LED_OutCnt,1			;减一次LED_OutCnt,到0跳下句
	GOTO	LOOP_BYTE				;继续LOOP_BYTE
	BCF	TRISA,2						;输出数字已准备好,设置TRISA,2输出
	BTFSC	LED_CS,0
	BSF	PORTA,2						;片选脚PORTA,2输出1,选十位数码管
	BTFSS	LED_CS,0
	BCF	PORTA,2						;片选脚PORTA,2输出0,选个位数码管
	CALL delay200ms					;延时200ms
	BSF	TRISA,2						;时间到，收回输出，设置片选高阻
	BTFSC	LED_CS,0				;如果LED_CS=0则设置1,如果是1设置为0
	BSF	LED_CS,0
	BTFSS	LED_CS,0
	BCF	LED_CS,0
	GOTO LOOP_LED
	
TABLE1	ADDWF	PCL,1
	RETLW        0X40;
	RETLW        0X79;
	RETLW        0X24;
	RETLW        0X30;
	RETLW        0X19;
	RETLW        0X12;
	RETLW        0X02;
	RETLW        0X58;
	RETLW        0X00;
	RETLW        0X10;

delay200ms	;调用延时子程序
	CLRF	Delay_Cnt0
delayLoopA	CLRF	Delay_Cnt1
delayLoopB	DECFSZ	Delay_Cnt1
	GOTO	delayLoopB
	DECFSZ	Delay_Cnt0
	GOTO	delayLoopA
	RETURN
	END
