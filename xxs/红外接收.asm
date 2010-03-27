list P=12F675
;常数
#define	TIME_DELAY	20
#define	
;地址
#define	DELAY		10H

	ORG		O0H
	GOTO	START
;###########
;中断服务程序
;###########
	ORG		O4H
	;保护中断现场
	MOVWF	W_TEMP
	SWAPF	STATUS,W
	MOVWF	S_TEMP
	;中断服务模式识别

;###########
;红外接收解码
;###########
IR_RECEIVE
	;检索头脉冲时间
RE_LOW
	BTFSC	SIGN
	GOTO	TEST_BIT
	; 延时TIME_DELAY微秒
	MOVLW	TIME_DELAY
	MOVWF	DELAY
	DECFSZ	DELAY,F
	GOTO	$-1
	INCF	COUNT,F
	
	