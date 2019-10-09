;/*********************************************************************************************************
;**
;**                                    �й�������Դ��֯
;**
;**                                   Ƕ��ʽʵʱ����ϵͳ
;**
;**                                       SylixOS(TM)
;**
;**                               Copyright  All Rights Reserved
;**
;**--------------�ļ���Ϣ--------------------------------------------------------------------------------
;**
;** ��   ��   ��: armCacheV8Asm.S
;**
;** ��   ��   ��: Wang.Xuan (���Q)
;**
;** �ļ���������: 2018 �� 02 �� 26 ��
;**
;** ��        ��: ARMv8 ��ϵ�ܹ� CACHE ͨ�ú���֧��.
;*********************************************************************************************************/

#ifndef ASSEMBLY
#define ASSEMBLY 1
#endif

#include <arch/assembler.h>
#include <config/kernel/cache_cfg.h>
#include <arch/arm64/arch_regs.h>

#if LW_CFG_CACHE_EN > 0

    FILE_BEGIN() 

    EXPORT_LABEL(arm64CacheCCSIDR)  
    EXPORT_LABEL(arm64CacheSetCSSELR)
    EXPORT_LABEL(arm64ICacheEnable)
    EXPORT_LABEL(arm64DCacheEnable)
    EXPORT_LABEL(arm64ICacheDisable)
    EXPORT_LABEL(arm64DCacheDisable)
    EXPORT_LABEL(arm64DCacheFlush)
    EXPORT_LABEL(arm64DCacheFlushAll)
    EXPORT_LABEL(arm64DCacheFlushPoU)
    EXPORT_LABEL(arm64DCacheClear)
    EXPORT_LABEL(arm64DCacheClearAll)
    EXPORT_LABEL(arm64DCacheInvalidate)
    EXPORT_LABEL(arm64DCacheInvalidateAll)
    EXPORT_LABEL(arm64ICacheInvalidate)
    EXPORT_LABEL(arm64ICacheInvalidateAll)
    EXPORT_LABEL(arm64ICacheInvalidateAllInner)

;/*********************************************************************************************************
;  ARM64 ��� CACHE ��ؼĴ���
;*********************************************************************************************************/

FUNC_DEF(arm64CacheCCSIDR)
    MRS     X0,  CCSIDR_EL1
    RET
    FUNC_END()

;/*********************************************************************************************************
;  ARM64 ���� CACHE ��ؼĴ���
;*********************************************************************************************************/

FUNC_DEF(arm64CacheSetCSSELR)
    MSR     CSSELR_EL1, X0
    RET
    FUNC_END()

;/*********************************************************************************************************
;  ARM64 ʹ�� CACHE
;*********************************************************************************************************/

FUNC_DEF(arm64ICacheEnable) 
    MOV     X13 , LR
    BL      arm64ICacheInvalidateAll
    MRS     X0  , SCTLR_EL1
    ORR     X0  , X0,  #(1 << 12)
    MSR     SCTLR_EL1, X0
    MOV     LR  , X13
    RET
    FUNC_END()

FUNC_DEF(arm64DCacheEnable)
    MRS     X0 , SCTLR_EL1
    ORR     X0 , X0, #(1 << 2)
    MSR     SCTLR_EL1 , X0
    RET
    FUNC_END()

;/*********************************************************************************************************
;  ARM64 ���� CACHE
;*********************************************************************************************************/

FUNC_DEF(arm64ICacheDisable)
    MRS     X0 , SCTLR_EL1
    BIC     X0 , X0 , #(1 << 12)
    MSR     SCTLR_EL1 , X0
    RET
    FUNC_END()

FUNC_DEF(arm64DCacheDisable)
    MRS     X0  , SCTLR_EL1
    AND     X0  , X0 , #(1 << 2)
    CMP     X0  , #0
    MOV     X13 , LR                                                    ;/*  ��¼���ص�ַ                */
    BEQ     dcache_not_en
    BL      arm64DCacheClearAll

    ARM_DSB()
    ARM_ISB()

    MRS     X0 ,  SCTLR_EL1
    BIC     X0 ,  X0 , #(1 << 2)
    MSR     SCTLR_EL1 , X0
    MOV     LR , X13
    RET

LINE_LABEL(dcache_not_en)            
    BL      arm64DCacheInvalidateAll  
    MOV     LR , X13
    RET
    FUNC_END()

;/*********************************************************************************************************
;  ARMv8 ���� DCACHE
;*********************************************************************************************************/

MACRO_DEF(armDCacheV8Op  Op  Kstart  Kend   LineSize  Tmp) 
    SUB     \Tmp ,    \LineSize , #1                                    ;/*  Tmp �洢 Cache Line ����    */
    BIC     \Kstart , \Kstart ,   \Tmp                                  ;/*  ȡ�����ַ                  */
1:
    DC      \Op ,     \Kstart                                           ;/*  ���� DCache ���ò���        */
    ADD     \Kstart , \Kstart ,   \LineSize                             ;/*  ÿ���ƶ� Cache Line ��С    */
    CMP     \Kstart , \Kend                                             ;/*  �Ƿ񵽴� End                */
    B.LO    1b
    ARM_DSB()
    RET
    MACRO_END()

;/*********************************************************************************************************
;  ARMv8 ��д ���� DCACHE      X0=void *start; X1=void *end; X2=cache line size
;*********************************************************************************************************/
FUNC_DEF(arm64DCacheFlushPoU)
    armDCacheV8Op   CVAU  X0  X1  X2  X3
    FUNC_END()

FUNC_DEF(arm64DCacheFlush)
    armDCacheV8Op   CVAC  X0  X1  X2  X3
    FUNC_END()

;/*********************************************************************************************************
;  ARM64 ��д����Ч���� DCACHE X0=void *start; X1=void *end; X2=cache line size
;*********************************************************************************************************/

FUNC_DEF(arm64DCacheClear)
    armDCacheV8Op   CIVAC  X0  X1  X2  X3
    FUNC_END()
    
;/*********************************************************************************************************
;  ARM64 ��Ч ���� DCACHE
;*********************************************************************************************************/

FUNC_DEF(arm64DCacheInvalidate)
    armDCacheV8Op   IVAC  X0  X1  X2  X3
    FUNC_END()

;/*********************************************************************************************************
;  ARMv8 DCACHE All ��ز���
;*********************************************************************************************************/

FUNC_DEF(arm64DCacheLevel)
    LSL     X12 , X0 , #1                                               ;/*  CSSELR_EL1 3-1 Ϊ Level ѡ��*/
    MSR     CSSELR_EL1 , X12                                            ;/*  ѡ�� Cache Level            */
    ARM_ISB()                                                           ;/*  ͬ�� CCSIDR_EL1             */
    MRS     X6 , CCSIDR_EL1                                             ;/*  ��ȡ CCSIDR_EL1             */
    AND     X2 , X6 , #7                                                ;/*  CCSIDR_EL1 2-0 Ϊ LineSize-4*/
    ADD     X2 , X2 , #4                                                ;/*  X2 ��¼ LineSize            */
    MOV     X3 , #0x3ff                                                 ;/*  CCSIDR_EL1 12-3  Ϊ ways - 1*/
    AND     X3 , X3 , X6 , LSR #3                                       ;/*  X3 ��¼���� ways          */
    CLZ     W5 , W3                                                     ;/*  ��¼ ways �� bit ��         */
    MOV     X4 , #0x7fff                                                ;/*  CCSIDR_EL1 27-13 Ϊ sets - 1*/
    AND     X4 , X4 , X6 , LSR #13                                      ;/*  X4 ��¼���� sets          */
                                                                        ;/*  X12 <- cache level << 1     */
                                                                        ;/*  X2  <- line size            */
                                                                        ;/*  X3  <- number of ways - 1   */
                                                                        ;/*  X4  <- number of sets - 1   */
                                                                        ;/*  X5  <- bit position of #ways*/
                                                                        ;/*  X1 = 0 clean only,          */
                                                                        ;/*  X1 = 1 clean and invalidate */
                                                                        ;/*  X1 = 2 invalidate only      */

LINE_LABEL(loop_set)                                                    ;/*  ���δ���ÿ�� set            */
    MOV     X6 , X3                                                     ;/*  X6 <- working copy of #ways */
LINE_LABEL(loop_way)                                                    ;/*  ���δ���ÿ�� way            */
    LSL     X7 , X6 , X5                                                ;/*  CISW 3 - 1 Ϊ Level         */
    ORR     X9 , X12, X7                                                ;/*  CISW 31- 4 Ϊ SetWay        */
    LSL     X7 , X4 , X2
    ORR     X9 , X9 , X7                                                ;/*  ��� SetWay ˵��            */
    TBZ     W1 , #0 , 1f                                                ;/*  �ж� X1                     */
    CMP     X1 , #2
    BNE     2f                                                          ;/*  ������� "ֻ����Ч" ����ת  */
    DC      ISW, X9                                                     ;/*  ֻ�� ��Ч  DCache           */
    B       3f
1:
    DC      CSW  ,  X9                                                  ;/*  ��д DCache                 */
2:
    DC      CISW , X9                                                   ;/*  ��д����Ч DCache           */
3:
    SUBS    X6 , X6 , #1                                                ;/*  �ݼ� way                    */
    B.GE    loop_way
    SUBS    X4 , X4 , #1                                                ;/*  �ݼ� set                    */
    B.GE    loop_set

    RET
    FUNC_END()

FUNC_DEF(arm64DCacheAll)
    MOV     X1  , X0
    ARM_DSB()
    MRS     X10 , CLIDR_EL1                                             ;/*  ��ȡ Cache Level ID         */
    LSR     X11 , X10 , #24                                             ;/*  CLIDR_EL1 24λΪ һ���Լ��� */
    AND     X11 , X11 , #0x7                                            ;/*  ��ȡһ���Լ���LOC��       */
    CBZ     X11 , finished                                              ;/*  ��� LOC Ϊ 0������         */
    MOV     X15 , LR                                                    ;/*  ��¼���ص�ַ                */
    MOV     X0  , #0                                                    ;/*  ��ʼ flush level 0 �� Cache */
                                                                        ;/*  X0  <- cache level          */
                                                                        ;/*  X10 <- clidr_el1            */
                                                                        ;/*  X11 <- LOC                  */
                                                                        ;/*  x15 <- return address       */
LINE_LABEL(loop_level)
    LSL     X12 , X0  , #1                                              ;/*  X12 <- Cache level << 1     */
    ADD     X12 , X12 , X0                                              ;/*  X12 <- 3 ���� Cache level   */
    LSR     X12 , X10 , X12
    AND     X12 , X12 , #7                                              ;/*  X12 ��¼ Cache Type         */
    CMP     X12 , #2                                                    ;/*  �Ƚ� Cache �����Ƿ�Ϊ DCache*/
    B.LT    skip                                                        ;/*  ������� DCache ������      */
    BL      arm64DCacheLevel                                            ;/*  X1 = 0 clean only,          */
                                                                        ;/*  X1 = 1 clean and invalidate */
                                                                        ;/*  X1 = 2 invalidate only      */
LINE_LABEL(skip)
    ADD     X0  , X0 , #1                                               ;/*  Cache Level ����            */
    CMP     X11 , X0                                                    ;/*  �Ƚ� Cache Level �������   */
    B.GT    loop_level
    MOV     X0  , #0
    MSR     CSSELR_EL1 , X0                                             ;/*  ���� CSSELR_EL1             */
    ARM_DSB()
    ARM_ISB()
    MOV     LR  , X15
      
LINE_LABEL(finished)
    RET
    FUNC_END()

;/*********************************************************************************************************
;  ARMv8 ��д ȫ�� DCACHE
;*********************************************************************************************************/

FUNC_DEF(arm64DCacheFlushAll)
    MOV     X14 , LR                                                    ;/*  ��¼���ص�ַ                */
    MOV     X0  , #0
    BL      arm64DCacheAll
    MOV     LR  , X14
    RET
    FUNC_END()

;/*********************************************************************************************************
;  ARMv8 ��д����Ч ȫ�� DCACHE
;*********************************************************************************************************/

FUNC_DEF(arm64DCacheClearAll)
    MOV     X14 , LR                                                    ;/*  ��¼���ص�ַ                */
    MOV     X0  , #1
    BL      arm64DCacheAll
    MOV     LR  , X14
    RET
    FUNC_END()

;/*********************************************************************************************************
;  ARM64 ��Ч ȫ�� DCACHE
;*********************************************************************************************************/

FUNC_DEF(arm64DCacheInvalidateAll)
    MOV     X14 , LR                                                    ;/*  ��¼���ص�ַ                */
    MOV     X0  , #1
    BL      arm64DCacheAll
    MOV     LR  , X14
    RET
    FUNC_END()

;/*********************************************************************************************************
;  ARM64 ��Ч���� ICACHE
;*********************************************************************************************************/

FUNC_DEF(arm64ICacheInvalidateAll)
    IC      IALLU
    ARM_ISB()
    RET
    FUNC_END()
    
;/*********************************************************************************************************
;  ARMv8 ��Ч���� ICACHE �� Inner Shareable
;*********************************************************************************************************/

FUNC_DEF(arm64ICacheInvalidateAllInner)
    IC      IALLUIS
    ARM_ISB()
    RET
    FUNC_END()

;/*********************************************************************************************************
;  ARM64 ��Ч ICACHE
;*********************************************************************************************************/

FUNC_DEF(arm64ICacheInvalidate)
    SUB     X3  , X2 , #1                                               ;/*  X3 �洢 Cache Line ����     */
    BIC     X0  , X0 , X3                                               ;/*  ȡ�����ַ                  */
1:
    IC      IVAU, X0                                                    ;/*  ���� ICache ���ò���        */
    ADD     X0  , X0 , X2                                               ;/*  ÿ���ƶ� Cache Line ��С    */
    CMP     X0  , X1                                                    ;/*  �Ƿ񵽴� End                */
    B.LO    1b
    DSB     ISH
    ARM_ISB()
    MOV     X0  , #0
    RET
    FUNC_END()

    FILE_END()
    
#endif
;/*********************************************************************************************************
;  END
;*********************************************************************************************************/