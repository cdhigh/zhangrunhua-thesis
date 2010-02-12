;----------------------------------------------------------
;项目名称：PIC12F629 IR
;
;项目简介：点滴版遥控器，该项目是这为了提高本论坛的人气而建
;造的。采用居有代表性的PIC12F629单片机，意图在于让初学者允分
;理解，PIC单片机的精简，低功耗。
;
;实现功能：PIC12F629工作于4MHz@3V。实现38KHz红外载波信号，编
;码数据调制。三个按键扫描，支持多路按键按下。按键按下，放开
;经过 20 * 500u 防抖处理。每次有效按键发送四组编码数据编码。
;在发送后，待机状态下PIC12F629进入睡眠。实现最低功耗待机。
;
;项目作者：点点滴滴 (PIC单片机初学论坛+编程技术交流)版主
;建造日期：2009年4月28日 至 2009年5月5日
;软件版本：V 1.01
;修改上版本源程序中的错误标号
;编译平台：MPASMWIN v5.30.01, mplink v4.30.01 MPLAB V8.30
;----------------------------------------------------------

;定义器件, 默认为十进制
        list P = 12f629, R = DEC

;加载头文件
		#include <p12f629.inc>

;熔丝配置：4M 振荡器，看门狗关，使能上电延时，内部复位，欠压检测关
 __CONFIG _HS_OSC & _WDT_OFF & _PWRTE_ON & _MCLRE_OFF & _BODEN_OFF

;----------------------------------------------------------
;脚位定义
#define	    LED_IR	GPIO,0

;时间常数
#define     BIT_T   1950
#define     BIT_1   1300
#define     BIT_0   650

;扫描次数
#define     SCAN    20

;4 组编码
#define     GROUP   4

;按键放开
#define     KEY_UP  00001110B

;换页操作
#define     BANK0   BCF STATUS,RP0
#define     BANK1   BSF STATUS,RP0

;操作周期
#define     NOP1    NOP
#define     NOP2    GOTO $+1

;内存分配
#define     BIT_CNT 20H
#define     TEMP    21H
#define     TEST    22H
#define     COUNT1  23H
#define     COUNT2  24H
#define     COUNT3  25H
#define     COUNT4  26H

;长按标志
#define     MARK    27H,0

;按键记录
#define     VALUE   28H
#define     RECORD  29H

;缓冲区
#define     BUFF_0  5CH
#define     BUFF_1  5DH
#define     BUFF_2  5EH
#define     BUFF_3  5FH

;----------------------------------------------------------
		ORG		0000H

        GOTO    START

;----------------------------------------------------------
;函数名称：START
;输入参数：无
;输出参数：无
;功能描述：上电初始化
;----------------------------------------------------------
        ORG     00006H
START:
		BANK0

;       GPIO 全部清零
        MOVLW   00000000B
        MOVWF   GPIO

;       关模拟比较器
		MOVLW 	00000111B
		MOVWF 	CMCON

;       使能电平变化唤醒
        MOVLW   00001000B
        MOVWF   INTCON

        BANK1
;                   |---- KEY2   按键输入
;                   ||--- KEY1   按键输入
;                   |||-- KEY0   按键输入
;                   ||||- LED_IR 发射输出
        MOVLW   00001110B
        MOVWF   TRISIO

;       上拉全部禁止
        MOVLW   10000000B
        MOVWF   OPTION_REG

;       GPIO 使能电平变化
        MOVLW   00001110B
        MOVWF   IOC

		BANK0

        GOTO    MAIN

;----------------------------------------------------------
;函数名称：PULSE
;输入参数：脉冲计数据 BIT_CNT
;输出参数：无
;功能描述：发送载波信号，频率 1 / 26us = 38.46KHz
;----------------------------------------------------------
PULSE:
;       LED_IR = 1 延时  8us
        BSF		LED_IR
        NOP1
        NOP2
        NOP2
        NOP2

;       LED_IR = 0 延时 18us
		BCF		LED_IR
        NOP2
        NOP2
        NOP2
        NOP2
        NOP2
        NOP2
        NOP2

;       循环发送倒计数
        DECFSZ  BIT_CNT,F
        GOTO    PULSE

;       函数返回
        RETURN

;----------------------------------------------------------
;函数名称：TX_SYNC
;输入参数：无
;输出参数：无
;功能描述：发送同步码载波信号
;----------------------------------------------------------
TX_SYNC:
;       发送 9000us 同步码载波信号
        MOVLW   2
        MOVWF   COUNT1

        MOVLW   (9000 / 26 / 2)
        MOVWF   COUNT2
SYNC:
;       LED_IR = 1 延时  8us
        BSF		LED_IR
        NOP1
        NOP2
        NOP2
        NOP2
HALF:
;       LED_IR = 0 延时 18us
		BCF		LED_IR
        NOP2
        NOP2
        NOP2
        NOP2
        NOP2
        NOP2
        NOP2

;       内循环发送倒计数
        DECFSZ  COUNT2,F
        GOTO    SYNC

;       时间补够 18us
        NOP1
        BSF		LED_IR

;       时间补够 8us
        NOP2

;       从新加载内循环发送倒计数
        MOVLW   (9000 / 26 / 2)
        MOVWF   COUNT2

;       外循环发送倒计数
        DECFSZ  COUNT1,F
        GOTO    HALF

;       时间补够 8us
        NOP1
        BCF     LED_IR

;       延时 4500us, 外循环计数
        MOVLW   (4500 / 500)
        MOVWF   COUNT1
DELAY1:
;       内循环计数
        MOVLW   ((500 - 2) / 3)
        MOVWF   COUNT2

        DECFSZ  COUNT2,F
        GOTO    $-1

        DECFSZ  COUNT1,F
        GOTO    DELAY1

;       函数返回
        RETURN

;----------------------------------------------------------
;函数名称：TX_BIT0
;输入参数：无
;输出参数：无
;功能描述：发送位'0'载波信号
;----------------------------------------------------------
TX_BIT0:
;       位'0' 脉冲常数
        MOVLW   ((BIT_T - BIT_0) / 26)
        MOVWF   BIT_CNT

;       发射载波信号
        CALL    PULSE

;       延时 650us
        MOVLW   ((BIT_0 - 2) / 3)
        MOVWF   COUNT1

        DECFSZ  COUNT1,F
        GOTO    $-1

;       函数返回
        RETURN

;----------------------------------------------------------
;函数名称：TX_BIT1
;输入参数：无
;输出参数：无
;功能描述：发送位'1'载波信号
;----------------------------------------------------------
TX_BIT1:
;       位'1' 脉冲常数
        MOVLW   ((BIT_T - BIT_1) / 26)
        MOVWF   BIT_CNT

;       发射载波信号
        CALL    PULSE

;       延时 1300us
        MOVLW   ((BIT_1 - 2) / 6)
        MOVWF   COUNT1

        NOP1
        NOP2
        DECFSZ  COUNT1,F
        GOTO    $-3

;       函数返回
        RETURN

;----------------------------------------------------------
;函数名称：TX_BYTE
;输入参数：等待发送的数据 TEMP
;输出参数：无
;功能描述：发送一字节数据
;----------------------------------------------------------
TX_BYTE:
;       测试数据位, 高位先行
        MOVLW   B'10000000'
        MOVWF   TEST
TEST_BIT:
;       测试一位数据
        ANDWF   TEMP,W

;       发送位'1'
        BTFSS   STATUS,Z
        CALL    TX_BIT1

;       发送位'0'
        BTFSC   STATUS,Z
        CALL    TX_BIT0

;       测试数据右移一位
        BCF     STATUS,C
        RRF     TEST,F

;       是否已经发送8位
        MOVF    TEST,W
        BTFSS   STATUS,Z
        GOTO    TEST_BIT

;       函数返回
        RETURN

;----------------------------------------------------------
;函数名称：TX_CODING
;输入参数：按键值 VALUE
;输出参数：无
;功能描述：发送四组数据编码
;----------------------------------------------------------
TX_CODING:
;       加载用户编码
        MOVLW   'I'
        MOVWF   BUFF_0

;       加载用户反码
        COMF    BUFF_0,W
        MOVWF   BUFF_1

;       加载数据编码
        MOVF    VALUE,W
        MOVWF   BUFF_2

;       加载数据反码
        COMF    BUFF_2,W
        MOVWF   BUFF_3

;       发送4组编码数据
        MOVLW   GROUP
        MOVWF   COUNT3
CODING:
;       发送缓冲区数据, 共4字节
        MOVLW   4
        MOVWF   COUNT4

;       加载缓冲区首址
        MOVLW   BUFF_0
        MOVWF   FSR

;       发送同步编码
        CALL    TX_SYNC
TX_DATA:
;       索引待发送的数据
        MOVF    INDF,W
        MOVWF   TEMP

;       缓冲区地址加1
        INCF    FSR,F

;       发送一字节数据
        CALL    TX_BYTE

;       一共发送4字节数据
        DECFSZ  COUNT4,F
        GOTO    TX_DATA

;       一共发送4组编码数据
        DECFSZ  COUNT3,F
        GOTO    CODING

;       函数返回
        RETURN

;----------------------------------------------------------
;函数名称：DELAY_500US
;输入参数：无
;输出参数：无
;功能描述：延时500us
;----------------------------------------------------------
DELAY_500US:
;       加载500us 延时常数
        MOVLW   ((500 - 2) / 3)
        MOVWF   COUNT1

        DECFSZ  COUNT1,F
        GOTO    $-1

;       函数返回
        RETURN

;----------------------------------------------------------
;函数名称：KEY_SCAN
;输入参数：无
;输出参数：按键值 VALUE
;功能描述：按键扫描
;----------------------------------------------------------
KEY_SCAN:
;       加载按键扫描常数
        MOVLW   SCAN
        MOVWF   COUNT2

KEY_READ:
;       500us 读取按键一次
        CALL    DELAY_500US

;       读取按键
        MOVLW   KEY_UP
        ANDWF   GPIO,W
        MOVWF   VALUE

;       新旧按键值对比
        XORWF   RECORD,W
        BTFSC   STATUS,Z

;       记录相同 顺利执行
        GOTO    $+3

;       记录不同 从新计数
        MOVLW   SCAN
        MOVWF   COUNT2

;       更新按键记录
        MOVF    VALUE,W
        MOVWF   RECORD

;       扫描按键计数
        DECFSZ  COUNT2,F
        GOTO    KEY_READ

;       函数返回
        RETURN

;----------------------------------------------------------
;函数名称：KEY_COM
;输入参数：按键值 VALUE
;输出参数：无
;功能描述：按键识别处理
;----------------------------------------------------------
KEY_COM:
;       按键放开识别
        MOVLW   KEY_UP
        XORWF   VALUE,W

        BTFSS   STATUS,Z
        GOTO    $+3

;       按键放开 清标志 离开
        BCF     MARK
        RETURN

;       按键按下 长按离开
        BTFSC   MARK
        RETURN

;       只执行一次 置标志
        BSF     MARK

;       发射完整的编码数据
        CALL    TX_CODING

;       读取按键值
        MOVLW   KEY_UP
        ANDWF   GPIO,W
        MOVWF   VALUE

;       按键放开检测
        MOVLW   KEY_UP
        XORWF   VALUE,W

;       按键已放开 清标示
        BTFSC   STATUS,Z
        BCF     MARK

;       函数返回
        RETURN

;----------------------------------------------------------
;函数名称：MAIN
;输入参数：无
;输出参数：无
;功能描述：主循环程序
;----------------------------------------------------------
MAIN:
;       清按键长按标志
        BCF     MARK
LOOP:
;       唤醒标示清零
        MOVF    GPIO,W
        BCF     INTCON,GPIF

;       系统进入睡眠
        SLEEP

;       按键唤醒
        NOP1

;       执行按键扫描
        CALL    KEY_SCAN

;       按键识别处理
        CALL    KEY_COM

;       循环执行程序
        GOTO	LOOP

;----------------------------------------------------------
		END
