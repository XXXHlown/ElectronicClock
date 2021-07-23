DATA SEGMENT
    ; 8086IO��
    IO2 EQU 0400H   ; 8253A
    IO4 EQU 0800H   ; 8255A 
    
    IO82530      EQU IO2      ; T0��ַ
    IO82531      EQU IO2 + 2  ; T1��ַ
    IO8253_CTR   EQU IO2 + 6  ; 8253A���ƿڵ�ַ
    
    IO8255A EQU IO4          ; 8255 A�ڵ�ַ
    IO8255B EQU IO4 + 2      ; 8255 B�ڵ�ַ
    IO8255C EQU IO4 + 4      ; 8255 C�ڵ�ַ 
    IO8255K  EQU  IO4 + 6 ; 8255 ���ƿڵ�ַ
    
    CNTVAL EQU 1000H ; ������ֵ
    
    LED DB 3FH,06H,5BH,4FH,66H,6DH,7DH,07H,7FH,6FH
    ;0--9 ��Ӧ��ѡ�룬������ 
    
    HOU DB 00H ; ʱ 
    MIN DB 00H ; �� 
    SEC DB 00H ; ��
    
DATA ENDS

STACK SEGMENT
    DW   200  DUP(0) 
STACK ENDS

CODE SEGMENT  
    ASSUME CS:CODE,DS:DATA,SS:STACK
    
START:
    ; ���ݶ�����
    MOV AX, DATA
    MOV DS, AX
    MOV ES, AX
    
    ; NMI�ж�������ʼ��
    PUSH ES
    XOR AX, AX 
    MOV ES, AX
    MOV AL, 02H ; NMI�ж����ͺ�Ϊ02H
    XOR AH, AH
    SHL AX, 1   
    SHL AX, 1   
    MOV SI, AX
    MOV AX, OFFSET NMI_SERVICE 
    MOV ES: [SI], AX
    INC SI
    INC SI
    MOV BX, CS
    MOV ES: [SI], BX
    POP ES   
    
    ; ��ʼ��8253
    MOV AL, 00110101B ; T0 ��д16λ ��ʽ2 BCD����
    MOV DX, IO8253_CTR   
    OUT DX, AL
    MOV DX, IO82530        
    MOV AX, CNTVAL    ; 1000��Ƶ
    OUT DX, AL
    
    MOV AL, AH        ; ���ֽ�
    OUT DX, AL
    
    MOV AL, 01110111B ; T1 ��д16λ ��ʽ3 BCD����
    MOV DX, IO8253_CTR   
    OUT DX, AL
    MOV DX, IO82531   
    MOV AX, CNTVAL    ; 1000��Ƶ
    OUT DX, AL
    
    MOV AL, AH        ; ���ֽ�
    OUT DX, AL   
    
    ; ��ʼ��8255
    MOV AL, 81H ; A��B�����C�ϲ�������²�����
    MOV DX, IO8255K
    OUT DX, AL
    
LP:
    ; ������
    CALL KEY
    CALL DISP    ; ��ʾ�ӳ������
    JMP LP       ; ѭ��

NMI_SERVICE: 
    ; �жϷ���
    PUSH AX
    MOV AL, SEC
    ADD AL, 1
    DAA          ; У��BCD���ӷ�    
    
    MOV SEC, AL
    CMP SEC, 60H 
    JB  EXIT      
    MOV SEC, 0
    MOV AL,  MIN
    ADD AL,  1
    DAA
    
    MOV MIN, AL
    CMP MIN, 60H
    JB  EXIT
    MOV MIN, 0
    MOV AL,  HOU
    ADD AL,  1
    DAA
    
    MOV HOU, AL
    CMP HOU, 24H
    JB  EXIT
    MOV HOU, 0
    
EXIT: 
    POP AX
    IRET       ; �жϷ���
          
DISP PROC 
     ; �������ʾ�ӳ���  
     MOV AL, 0FFH   ; ����ʾ
     MOV DX, IO8255B
     OUT DX, AL     ; λѡ�źŽӵ�8255A��PB��
     
     ; ���λ
     MOV AL, 0FEH    ;��ѡ���λ AL=1111 1110
     MOV DX, IO8255B          
     OUT DX, AL     ; λѡ  
     
     MOV BL, SEC    
     AND BX, 000FH   ; ��4λ����Ϊ���λ
     MOV SI, BX 
     MOV AL, LED[SI]  ;����ΪLED�ֶε�SI��
     MOV DX, IO8255A  
     OUT DX, AL       ; ��ѡ
     CALL DELAY            
   
     MOV AL, 0FFH   ; Ϊ��ֹ�ص���ÿ����ʾ֮ǰҪ����
     MOV DX, IO8255B
     OUT DX, AL       
     
     MOV BL, SEC       ;ͬ��ȡ��ʮλ����SI
     AND BX, 00F0H
     MOV CL, 4
     SHR BX, CL      
     MOV SI, BX
 
     MOV AL, 0FDH   ; ��ʮλ��AL=1111 1101
     MOV DX, IO8255B          
     OUT DX, AL
             
     MOV AL, LED[SI]  ; ����
     MOV DX, IO8255A
     OUT DX, AL
     CALL DELAY          
     
     MOV AL, 0FFH   ; ����ʾ
     MOV DX, IO8255B
     OUT DX, AL  
                
     MOV AL, 40H    ; "-"����  
     MOV DX, IO8255A
     OUT DX, AL
     
     MOV AL, 0FBH   ; "-"λ,AL=1111 1011
     MOV DX, IO8255B
     OUT DX, AL
     CALL DELAY   
     
     MOV AL, 0FFH   ; ����ʾ
     MOV DX, IO8255B
     OUT DX, AL    
     
     MOV BL, MIN
     AND BX, 000FH
     MOV SI, BX
     MOV AL, LED[SI]  ; ����
     MOV DX, IO8255A
     OUT DX, AL
     
     MOV AL, 0F7H     ; �ָ�λ��AL=1111 0111
     MOV DX, IO8255B
     OUT DX, AL
     CALL DELAY  
                      
     MOV AL, 0FFH     ; ����ʾ
     MOV DX, IO8255B
     OUT DX, AL  
     
     MOV BL, MIN
     AND BX, 00F0H
     MOV CL, 4
     SHR BX, CL       
     MOV SI, BX
     MOV AL, LED[SI]  ; ���� 
     MOV DX, IO8255A
     OUT DX, AL
     
     MOV AL, 0EFH   ; ��ʮλ,AL=1110 1111
     MOV DX, IO8255B          
     OUT DX, AL
     CALL DELAY  
     
     MOV AL, 0FFH   ; ����ʾ
     MOV DX, IO8255B
     OUT DX, AL   
     
     MOV AL, 40H    ; ���롰-��  
     AND DX, IO8255A
     OUT DX, AL
     
     MOV AL, 0DFH   ; "-"λ,AL=1101 1111
     MOV DX, IO8255B
     OUT DX, AL
     CALL DELAY 
     
     MOV AL, 0FFH   ; ����ʾ
     MOV DX, IO8255B
     OUT DX, AL    

     MOV BL, HOU
     AND BX, 000FH
     MOV SI, BX
     MOV AL, LED[SI]  ; ����
     MOV DX, IO8255A
     OUT DX, AL
     
     MOV AL, 0BFH     ; ʱ��λ,AL=1011 1111
     MOV DX, IO8255B
     OUT DX, AL
     CALL DELAY               
     
     MOV AL, 0FFH     ; ����ʾ
     MOV DX, IO8255B
     OUT DX, AL  
     
     MOV BL, HOU
     AND BX, 00F0H
     MOV CL, 4
     SHR BX, CL       
     MOV SI, BX
     MOV AL, LED[SI]  ; ���� 
     MOV DX, IO8255A
     OUT DX, AL  
     
     MOV AL, 07FH     ; ʱʮλ,AL=0111 1111
     MOV DX, IO8255B
     OUT DX, AL
     CALL DELAY
     
     RET              ; �ӳ��򷵻�
DISP ENDP
          
KEY   PROC
    MOV DX, IO8255C     
    IN AL, DX
    TEST AL, 8H       ;��һ�μ��
    JZ NEXTHOU 
    TEST AL, 4H     
    JZ NEXTMIN
    TEST AL, 2H      
    JZ NEXTSEC
    TEST AL, 1H
    JZ RESET
    CALL DISP       ; ����
    CALL DISP 
    CALL DISP
    MOV DX, IO8255C
    IN AL, DX
    TEST AL, 8H       ;�ڶ��μ��
    JZ NEXTHOU 
    TEST AL, 4H
    JZ NEXTMIN
    TEST AL, 2H
    JZ NEXTSEC
    TEST AL, 1H
    JZ RESET

NEXTHOU: 
    ; ʱ+1
    MOV DX, IO8255C
    IN AL, DX
    TEST AL, 8H         ;�����μ��
    JNZ EXITKEY  
    CALL DISP           ;�ճ�����
    CALL DISP
    CALL DISP
    MOV DX, IO8255C
    IN AL, DX
    TEST AL, 8H          ;���Ĵμ��
    JNZ EXITKEY
    MOV AL, HOU
    ADD AL, 1     
    DAA 
    CALL DELAY   
    
    MOV HOU, AL
    CMP HOU, 24H
    JB NEXTHOU
    MOV HOU, 0

NEXTMIN: 
    ; ��+1
    MOV DX, IO8255C
    IN AL, DX
    TEST AL, 4H         ;�����μ��
    JNZ EXITKEY  
    CALL DISP           ;�ճ�����
    CALL DISP
    CALL DISP
    MOV DX, IO8255C
    IN AL, DX
    TEST AL, 4H          ;���Ĵμ��
    JNZ EXITKEY
    MOV AL, MIN
    ADD AL, 1
    DAA      
    CALL DELAY 
    
    MOV MIN, AL
    CMP MIN, 60H
    JB NEXTMIN
    MOV MIN, 0    

NEXTSEC: 
    ; ��+1
    MOV DX, IO8255C
    IN AL, DX
    TEST AL, 2H          ;�����μ��
    JNZ EXITKEY  
    CALL DISP            ;�ճ�����
    CALL DISP
    CALL DISP
    MOV DX, IO8255C
    IN AL, DX
    TEST AL, 2H
    JNZ EXITKEY          ;���Ĵμ��
    MOV AL, SEC
    ADD AL, 1
    DAA         
    CALL DELAY        
    MOV SEC, AL
    CMP SEC, 60H
    JB NEXTSEC
    MOV SEC, 0

RESET: 
    ; ����
    MOV DX, IO8255C
    IN AL, DX
    TEST AL, 1H          ;�����μ��
    JNZ EXITKEY  
    CALL DISP           ;�ճ�����
    CALL DISP
    CALL DISP
    MOV DX, IO8255C
    IN AL, DX
    TEST AL, 1H          ;���Ĵμ��
    JNZ EXITKEY    
    MOV HOU, 0
    MOV MIN, 0
    MOV SEC, 0
    CALL DELAY
    
EXITKEY:
    RET
    
KEY ENDP

DELAY PROC
      ; ��ʱ�ӳ��� 
      PUSH BX
      PUSH CX
      MOV BX, 1
LP1:  MOV CX, 1000
LP2:  LOOP LP2
      DEC BX
      JNZ LP1
      POP CX
      POP BX   
      RET    
DELAY ENDP
               
CODE ENDS

    END START 
