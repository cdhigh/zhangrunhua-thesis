;��HOLTEK�ĳ���Ĺ����ģ� ����ָ������鷳�����޸����� ����
;ֻ����Ҫ���� �����������Լ�����������
;*****************************************************************
;ѧϰ���ܣ� ��һ���µ�ң��ʱ������ʹ�ô˹���ȷ�ϸ�ң��ΪΨһ��ң�أ�
;ȷ����ң�غ󣬾�ң����Ч
;*****************************************************************
;�ؼ�����
; remote EV1527�������IO
; C ��λ
; z ZERO��־
; ccl, cch �ֹ�������
; leader, LEADER�룬 ����EV1527�н���ʱ������124CLK���͵�ƽ
; code_buf_1 ~ 3  ��¼��ǰ���յ���24BIT
; code_dd_1 ~ 3 ��Ӧ��ң�أ�Ψһ�ĳ����룬����ʹ�ó����ѧϰ���������壩
; buf_remote_1 ~ 3 ѧϰʱʹ�õĻ���
; code_keep ��ǰ����ס���ŵı�־
; xuexi_key  �������룬 ������Ч
main:
			clrwdt
;������һ
re_add:
			btfsc		remote		;io
			goto		turn_high
			clrwdt
			incf	ccl,1
			btfsc	C		;carry
			incf	cch.1
			goto	re_add
turn_high
			clr		int_ext			;����һ�����ν������ȴ�����
no_ever_low:
;==============================================================
no_caling:
			btfsc	remote
			goto	main
			CLR		ccl
			CLR		cch
			goto	re_add
;�ص㲿�֣� ����
;ȷ����ң���жϣ�
int_ext:
;1���ж�leader code
			btfsz	leader
			goto	incoding
config_leader:
		movlw	d'6'			;���� 4MHZ����Ļ�
		subwf	cch,0
		btfss		C
		goto	code_error		;
		bsf		leader
		goto	exit_int
;*********************************************************
;*********************************************************
incoding:
;���տͻ���ͼ�����
		MOVlw	d'111'				;4MHZ�� 111�� �Լ�����
		subwf	ccl,0
		RLC			code_buf3
		RLC			code_buf2
		RLC			code_buf1
		movlw	d'24'
		subwf		code_counter
		btfss		z			; z 0��־
		goto		exit_int
;*****************************************************************
;���չ�24BIT
;*****************************************************************
;*****************************************************************
;ѧϰ���ܣ� ��һ���µ�ң��ʱ������ʹ�ô˹���ȷ�ϸ�ң��ΪΨһ��ң�أ�
;ȷ����ң�غ󣬾�ң����Ч
;*****************************************************************
		;�õ���ȷ��ң���룬���ü���
		btfsc	xuexi_key		; �жϰ���
		jmp		nn_key_keep	;������ѧϰ״̬�� ��������ң����
;*********************************************************
		;�жϵ���ѧϰ�Ƿ����
		btfsc		code_configed
		goto		exit_int
		movf	code_buf1,0
		xorwf	buf_remote_1,0
		btfss	z
		goto	error_keep			;ǰ���벻��ͬ
		movf	code_buf2,0
		xorwf	buf_remote_2,0
		btfss	z
		goto	error_keep			;ǰ���벻��ͬ
		movf	code_buf3,0
		xorwf	buf_remote_3,0
		btfss	z
		goto	error_keep			;ǰ���벻��ͬ
		;same code
		movf	buf_remote_time��0	;�ж�ѧϰʱ�䣬 �������뱣��һ��ʱ�䣬��ֹ������� ����5��
		btfss	z
		goto	nz_buf_remote_time
		;ѧϰ���
		movf	buf_remote_1,0
		movwf	code_dd_1
		movf	buf_remote_2,0
		movwf	code_dd_2
		movlw	#0f0h
		andwf	buf_remote_3,0
		mvowf	code_dd_3
		CALL EEPROM_WRITE ;��ң��ʶ����浽EEPROM�� �´��ϵ��ʱ�����
		                  ;EEPROM�����������������۷�Χ����д�ˣ�����
		goto	exit_int		;����
;*********************************************************
;*********************************************************
nz_buf_remote_time:
		decf		buf_remote_time,1
		goto		exit_int
error_keep:
		movf	code_buf1,0
		movwf	buf_remote_1
		movf	code_buf2,0
		movwf	buf_remote_2
		movf	code_buf3,0
		movwf	buf_remote_3
		mov		a,	100					;ѧϰʱ�䣬���Լ�ϰ��������
		mov		buf_remote_time,	a
		goto	exit_int
;*********************************************************
;��ѧϰʱ�Ľ���
;*********************************************************
nn_key_keep:
		movf	code_dd_1,0
		xorwf	code_buf1,0
		btfss	z
		goto	code_error
		movf	code_dd_2,0
		xorwf	code_buf2,0
		btfss	z
		goto	code_error
		movlw	#0f0h
		andwf	code_dd_3,0
		xorwf	code_buf3,0
		btfss	z
		goto	code_error
		movf	remote_time,0			;ң�ط�����ʱ�䣬��Ϊ1527���������ϵķ�24BIT��,���Կ�������ȷ��ʱ��
		btfss	z
		goto	dec_remote_time
		btfsc	code_keep			;bit ����
		goto	exit_int
		set		code_keep				;��ǰ����ס���ŵı�־
;*************************************************************
		movlw	#0fh
		andwf	code_buf3,0
;*************************************************************
;ȷ��һ����Ч��ң�ذ���
;*************************************************************
		;���˽������ W �д���˵�ǰ�ļ�ֵ�� ���߲����
		;���������صļ�����ָ��
;*************************************************************
;*************************************************************
		goto	exit_int
;*************************************************************
dec_remote_time:
		dec		remote_time
		jmp		exit_int
;*************************************************************
;*************************************************************
code_error:
		bcf		leader
		CLR		code_buf_1
		CLR		code_buf_2
		CLR		code_buf_3
		CLR		code_counter
		bcf		code_configed		;��ң���ź����ͷŵ�ǰ��ѧϰ��ȷ��־
		mov		a,	dat_remote_time
		mov		remote_time,	a
;*************************************************************
exit_int:
		jmp		main