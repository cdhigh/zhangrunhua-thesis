;----------------------------------------------------------
;定义器件, 默认为十进制
    list P = 12f675, R = DEC
;加载头文件           
#include <p12f675.inc>       
;熔丝配置：20M振荡器，看门狗关，使能上电延时，内部复位，欠压检测开
 __CONFIG _HS_OSC & _WDT_OFF & _PWRTE_ON & _MCLRE_OFF & _BODEN_ON
;----------------------------------------------------------
;时间常数
#define	TIME_DECO	1600
#define	TIME_DELAY	20
;电平时间计数
#define COUNT   	2EH
#define DELAY		2FH
;共接收BYTE*BIT位数据
#define     BYTE    2CH
#define     BIT     2DH
;中断现场保护寄存地址
#define     W_TEMP  2AH
#define     S_TEMP  2BH
;红外信号接收缓存区(4Byte缓存32个位的脉冲)
#define     BUFF_0  5CH
#define     BUFF_1  5DH
#define     BUFF_2  5EH
#define     BUFF_3  5FH
;各动作的测试码，如果接收的信号是
;下面的其中一个值，就执行相应操作
;理论可以扩展2^8-2=254种情况（排除2个全0全1情况）
#define     KEY_1  B'00000001'
#define     KEY_2  B'00000010'
#define     KEY_3  B'00000011'
#define     KEY_4  B'00000100'
#define     KEY_5  B'00000101'
#define     KEY_6  B'00000110'
#define     KEY_7  B'00000111'
;红外输入在GPIO,0
#define     INPUT	GPIO,0
;---------------------------------------------------------------
;程序开始，由于中断跳到04H，所以主程序在00H设置跳转到START
;---------------------------------------------------------------
	ORG		O0H
	GOTO	START
;---------------------------------------------------------------
;中断服务程序
;中断时候，PIC自动由04H开始执行程序。
;---------------------------------------------------------------
	ORG		O4H
	;保护中断现场
	MOVWF	W_TEMP
	SWAPF	STATUS,W
	MOVWF	S_TEMP
	;中断服务模式识别
START
;---------------------------------------------------------------
;红外接收解码
;调用路径示意：
;IR_RECEIVE->{RECE->CHECK_LOW(TEST_BIT->CHECK_HIGH(CHECK_BIT))->NEXT_BIT}
;其中{}代表循环执行；()代表调用子函数；->代表顺序执行
;----------------------------------------------------------
IR_RECEIVE
	;共4字节数据
	MOVLW   4
	MOVWF   BYTE
	;每字节8位
	MOVLW   8
	MOVWF   BIT
RECE
	;计数值清零
    CLRF   COUNT
	;检测信号低电平部分时间长度
CHECK_LOW
	;输入信号在INPUT
	BTFSC	INPUT
	GOTO	TEST_BIT	;调用TEST_BIT，CHECK_BIT检测此bit是否正确
	;延时TIME_DELAY=20微秒（1uS/1次循环）
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
	;时间溢出IR_RECEIVE结束返回
    RETURN
TEST_BIT	;由CHECK_LOW调用,执行到CHECK_BIT结束返回CHECK_LOW
	;数据位测试
	MOVLW   ((TIME_DECO / 5) / 20)
	SUBWF   COUNT,W
	;脉冲时间过窄IR_RECEIVE结束返回
	BTFSS   STATUS,C
	RETURN
	;数据位识别
	MOVF    COUNT,W
	SUBLW   ((TIME_DECO / 2) / 20)
	;(TIME_DECO / 2 / 20) < COUNT C = 0 数据位 = 0
	;(TIME_DECO / 2 / 20) > COUNT C = 1 数据位 = 1
	;记录一位数位 高位在先 低位在后
	RLF     INDF,F
CHECK_HIGH
	;检测信号高电平部分时间长度
	;输入信号在INPUT
	BTFSS   INPUT
	GOTO    CHECK_BIT
	;延时匹配 周期为 20us
	MOVLW   TIME_DELAY
	MOVWF   DELAY
	DECFSZ  DELAY,F
	GOTO    $-1
	;计数值递增
	INCF    COUNT,F
	;信号限定时间最大 +20%
	MOVLW   ((TIME_DECO * 6 / 5) / 20)
	SUBWF   COUNT,W
	;时间是否溢出
	BTFSS   STATUS,C
	GOTO    CHECK_HIGH
	;时间溢出IR_RECEIVE结束返回
	RETURN
CHECK_BIT
	;信号限定最小时间 -20%
	MOVLW   ((TIME_DECO * 8 / 10) / 20)
	SUBWF   COUNT,W
	;时间是否过窄
	BTFSS   STATUS,C
	;信号过窄返回
	RETURN	;TEST_BIT执行到此返回
NEXT_BIT
	;成功接收一位数据，BIT指针+1
	DECFSZ  BIT,F
	GOTO    RECE
	;每字节8位
	MOVLW   8
	MOVWF   BIT
	;指向下个缓冲区
	INCF    FSR,F
	;BYTE自增，共接收4个字节结束
	DECFSZ  BYTE,F
	GOTO    RECE
	;_________________________________
	;到此已经接收4字节数据到BUFF_0~3
	;_________________________________
	;前两字节:用户正反码对比
	COMF    BUFF_0,W
	XORWF   BUFF_1,F
	;校验失败离开
	BTFSS   STATUS,Z
	RETURN
	; 数据正反码对比
    COMF    BUFF_2,W
    XORWF   BUFF_3,F
	;校验失败 离开
	BTFSS   STATUS,Z
	RETURN
	;红外动作1识别
	MOVF    BUFF_2,W
	XORLW   KEY_1
	BTFSC   STATUS,Z
	GOTO    KEY_1_F
	;红外动作2识别
	MOVF    BUFF_2,W
	XORLW   KEY_2
	BTFSC   STATUS,Z
	GOTO    KEY_2_F
	;红外动作3识别
	MOVF   BUFF_2,W
	XORLW   KEY_3
	BTFSC   STATUS,Z
	GOTO    KEY_3_F
	;红外动作4识别
	MOVF   BUFF_2,W
	XORLW   KEY_4
	BTFSC   STATUS,Z
	GOTO    KEY_4_F
	;红外动作5识别
	MOVF   BUFF_2,W
	XORLW   KEY_5
	BTFSC   STATUS,Z
	GOTO    KEY_5_F
	;红外动作6识别
	MOVF   BUFF_2,W
	XORLW   KEY_6
	BTFSC   STATUS,Z
	GOTO    KEY_6_F
	;红外动作7识别
	MOVF   BUFF_2,W
	XORLW   KEY_7
	BTFSC   STATUS,Z
	GOTO    KEY_7_F
	;不匹配以上全部情况视作无效按键码离开
    RETURN
;----------------------------------------------------------
;过程名称：MAIN
;功能描述：主循环程序
;----------------------------------------------------------
MAIN
;       变量全部清零
	CLRF    INDEX
	CLRF    MARK
	CLRF    DUTY
;       默认渐变模式
	MOVLW   MICRO
	MOVWF   FUNC
;       加载定时器初值
	MOVLW   TIME_VALUE
	MOVWF   TMR0
;       启动中断
	BSF     INTCON,GIE
LOOP
;       红外接收解码
	CALL    DECODE
;       循环执行程序
	GOTO LOOP
    END
;----------------------------------------------------------
;过程名称：红外接收动作
;功能描述：7种红外信号对应7种动作
;----------------------------------------------------------.
;红外动作1执行：
KEY_1_F
	MOVLW	B'00000000'
	MOVWF	OUT_DATA
	CALL	OUT_74164
	RETURN
	