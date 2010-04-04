list P=12F675
;常数
;时间常数
#define	TIME_DECO	1600      ;1950
#define	TIME_DELAY	20        ;30
;电平时间计数
#define COUNT   	2EH
#define DELAY		2FH
;共接收BYTE*BIT位数据
#define     BYTE    2CH
#define     BIT     2DH
;中断现场保护寄存
#define     W_TEMP  2AH
#define     S_TEMP  2BH
;红外信号接收缓存区
#define     BUFF_0  5CH
#define     BUFF_1  5DH
#define     BUFF_2  5EH
#define     BUFF_3  5FH
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
START
;###########
;红外接收解码
;###########
IR_RECEIVE
	;共4字节数据
	MOVLW   4
	MOVWF   BYTE
	;每字节8位
	MOVLW   8
	MOVWF   BIT
	;检测信号头低电平部分时间长度
CHECK_LOW
	;输入信号在GPIO,0
	BTFSC	GPIO,0
	GOTO	TEST_BIT	;调用TEST_BIT，CHECK_BIT检测此bit是否正确
	;延时TIME_DELAY微秒（1uS/1次循环）
	MOVLW	TIME_DELAY
	MOVWF	DELAY
	DECFSZ	DELAY,F
	GOTO	$-1
	INCF	COUNT,F
	;信号误差时间不超过+20%
	MOVLW	((TIME_DECO * 6 / 5) / 20)
	SUBWF	COUNT,W
	;时间是否溢出
    BTFSS   STATUS,C
    GOTO    CHECK_LOW
	;时间溢出离开
    RETURN
TEST_BIT	;由CHECK_LOW调用,执行到CHECK_BIT结束返回CHECK_LOW
	;数据位测试
	MOVLW   ((TIME_DECO / 5) / 20)
	SUBWF   COUNT,W
	;脉冲时间过窄 离开
	BTFSS   STATUS,C
	RETURN
	;数据位识别
	MOVF    COUNT,W
	SUBLW   ((TIME_DECO / 2) / 20)
	;(TIME_DECO / 2 / 20) < COUNT C = 0 数据位 = 0
	;(TIME_DECO / 2 / 20) > COUNT C = 1 数据位 = 1
	;记录一位数位 高位在先 低位在后
	RLF     INDF,F
CHECK_BIT	;CHECK_LOW执行到CHECK_BIT,然后回
	;信号限定最小时间 -20%
	MOVLW   ((TIME_DECO * 8 / 10) / 20)
	SUBWF   COUNT,W
	;时间是否过窄
	BTFSS   STATUS,C
	;信号过窄离开
	RETURN
NEXT_BIT:
	;成功接收一位数据
	DECFSZ  BIT,F
	GOTO    RECE_SUCCESS
	;每字节8 位
	MOVLW   8
	MOVWF   BIT
	;指向下个缓冲区
	INCF    FSR,F
	;共接收4 个字节
	DECFSZ  BYTE,F
	GOTO    RECE_SUCCESS
RECE