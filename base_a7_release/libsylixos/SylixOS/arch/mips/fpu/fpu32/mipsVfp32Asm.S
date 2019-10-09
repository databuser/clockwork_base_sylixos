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
;** ��   ��   ��: mipsVfp32Asm.S
;**
;** ��   ��   ��: Jiao.JinXing (������)
;**
;** �ļ���������: 2015 �� 11 �� 17 ��
;**
;** ��        ��: MIPS ��ϵ�ܹ� VFP32 ֧��.
;*********************************************************************************************************/

#ifndef ASSEMBLY
#define ASSEMBLY 1
#endif

#include <arch/assembler.h>

#if LW_CFG_CPU_FPU_EN > 0
#include "arch/mips/arch_float.h"

    FILE_BEGIN()

    EXPORT_LABEL(mipsVfp32Init)
    EXPORT_LABEL(mipsVfp32Enable)
    EXPORT_LABEL(mipsVfp32Disable)
    EXPORT_LABEL(mipsVfp32IsEnable)
    EXPORT_LABEL(mipsVfp32Save)
    EXPORT_LABEL(mipsVfp32Restore)
    EXPORT_LABEL(mipsVfp32GetFIR)
    EXPORT_LABEL(mipsVfp32GetFCSR)
    EXPORT_LABEL(mipsVfp32SetFCSR)

;/*********************************************************************************************************
;  ʹ�� FPU(ֻ���ƻ� T0 �Ĵ���)
;*********************************************************************************************************/

MACRO_DEF(ENABLE_FPU)
    MFC0_EHB(T0, CP0_STATUS)
#if LW_CFG_CPU_WORD_LENGHT == 64
    OR      T0 , T0 , ST0_CU1 | ST0_FR
#else
    OR      T0 , T0 , ST0_CU1
    AND     T0 , T0 , ~ST0_FR
#endif
    MTC0_EHB(T0, CP0_STATUS)
    MACRO_END()

;/*********************************************************************************************************
;  ��ʼ�� FPU
;*********************************************************************************************************/

FUNC_DEF(mipsVfp32Init)
    MFC0_EHB(T1, CP0_STATUS)                                            ;/*  T1 = ԭ FPU ����״̬        */

    ENABLE_FPU                                                          ;/*  ʹ�� FPU                    */

#if LW_CFG_CPU_WORD_LENGHT == 64
    DMTC1   ZERO , $f1                                                  ;/*  ���� FPU ������żĴ���     */
    DMTC1   ZERO , $f3
    DMTC1   ZERO , $f5
    DMTC1   ZERO , $f7
    DMTC1   ZERO , $f9
    DMTC1   ZERO , $f11
    DMTC1   ZERO , $f13
    DMTC1   ZERO , $f15
    DMTC1   ZERO , $f17
    DMTC1   ZERO , $f19
    DMTC1   ZERO , $f21
    DMTC1   ZERO , $f23
    DMTC1   ZERO , $f25
    DMTC1   ZERO , $f27
    DMTC1   ZERO , $f29
    DMTC1   ZERO , $f31

    DMTC1   ZERO , $f0                                                 ;/*  ���� FPU ż����żĴ���      */
    DMTC1   ZERO , $f2
    DMTC1   ZERO , $f4
    DMTC1   ZERO , $f6
    DMTC1   ZERO , $f8
    DMTC1   ZERO , $f10
    DMTC1   ZERO , $f12
    DMTC1   ZERO , $f14
    DMTC1   ZERO , $f16
    DMTC1   ZERO , $f18
    DMTC1   ZERO , $f20
    DMTC1   ZERO , $f22
    DMTC1   ZERO , $f24
    DMTC1   ZERO , $f26
    DMTC1   ZERO , $f28
    DMTC1   ZERO , $f30

#else
    MTC1    ZERO , $f0                                                  ;/*  ���� FPU �Ĵ���             */
    MTC1    ZERO , $f1
    MTC1    ZERO , $f2
    MTC1    ZERO , $f3
    MTC1    ZERO , $f4
    MTC1    ZERO , $f5
    MTC1    ZERO , $f6
    MTC1    ZERO , $f7
    MTC1    ZERO , $f8
    MTC1    ZERO , $f9
    MTC1    ZERO , $f10
    MTC1    ZERO , $f11
    MTC1    ZERO , $f12
    MTC1    ZERO , $f13
    MTC1    ZERO , $f14
    MTC1    ZERO , $f15
    MTC1    ZERO , $f16
    MTC1    ZERO , $f17
    MTC1    ZERO , $f18
    MTC1    ZERO , $f19
    MTC1    ZERO , $f20
    MTC1    ZERO , $f21
    MTC1    ZERO , $f22
    MTC1    ZERO , $f23
    MTC1    ZERO , $f24
    MTC1    ZERO , $f25
    MTC1    ZERO , $f26
    MTC1    ZERO , $f27
    MTC1    ZERO , $f28
    MTC1    ZERO , $f29
    MTC1    ZERO , $f30
    MTC1    ZERO , $f31
#endif

    CTC1_EHB(ZERO, CP1_STATUS)

    MTC0_EHB(T1 , CP0_STATUS)                                           ;/*  �ָ�ԭ FPU ����״̬         */
    JR      RA
    NOP
    FUNC_END(mipsVfp32Init)

;/*********************************************************************************************************
;  ʹ�� FPU
;*********************************************************************************************************/

FUNC_DEF(mipsVfp32Enable)
    ENABLE_FPU                                                          ;/*  ʹ�� FPU                    */
    JR      RA
    NOP
    FUNC_END(mipsVfp32Enable)

;/*********************************************************************************************************
;  ���� FPU
;*********************************************************************************************************/

FUNC_DEF(mipsVfp32Disable)
    MFC0_EHB(T0, CP0_STATUS)
    AND     T0 , T0 , ~ST0_CU1
    MTC0_EHB(T0, CP0_STATUS)
    JR      RA
    NOP
    FUNC_END(mipsVfp32Disable)

;/*********************************************************************************************************
;  �ж� FPU �Ƿ�ʹ��
;*********************************************************************************************************/

FUNC_DEF(mipsVfp32IsEnable)
    MOV     V0 , ZERO                                                   ;/*  FALSE return value          */
    MFC0_EHB(T0, CP0_STATUS)
    AND     T0 , T0 , ST0_CU1                                           ;/*  coprocessor 1 enabled       */
    BEQ     T0 , ZERO, 1f
    NOP
    LI      V0 , 1                                                      ;/*  TRUE return value           */
1:
    JR      RA
    NOP
    FUNC_END(mipsVfp32IsEnable)

;/*********************************************************************************************************
;  ���� FPU �Ĵ���
;*********************************************************************************************************/

FUNC_DEF(mipsVfp32Save)
    ENABLE_FPU                                                          ;/*  ʹ�� FPU                    */

    CFC1_EHB(T1,  CP1_STATUS)

#if LW_CFG_CPU_WORD_LENGHT == 64
    SDC1    $f1  , FPU_OFFSET_REG(1)(A0)                                ;/*  ���� FPU ������żĴ���     */
    SDC1    $f3  , FPU_OFFSET_REG(3)(A0)
    SDC1    $f5  , FPU_OFFSET_REG(5)(A0)
    SDC1    $f7  , FPU_OFFSET_REG(7)(A0)
    SDC1    $f9  , FPU_OFFSET_REG(9)(A0)
    SDC1    $f11 , FPU_OFFSET_REG(11)(A0)
    SDC1    $f13 , FPU_OFFSET_REG(13)(A0)
    SDC1    $f15 , FPU_OFFSET_REG(15)(A0)
    SDC1    $f17 , FPU_OFFSET_REG(17)(A0)
    SDC1    $f19 , FPU_OFFSET_REG(19)(A0)
    SDC1    $f21 , FPU_OFFSET_REG(21)(A0)
    SDC1    $f23 , FPU_OFFSET_REG(23)(A0)
    SDC1    $f25 , FPU_OFFSET_REG(25)(A0)
    SDC1    $f27 , FPU_OFFSET_REG(27)(A0)
    SDC1    $f29 , FPU_OFFSET_REG(29)(A0)
    SDC1    $f31 , FPU_OFFSET_REG(31)(A0)
#endif

    SDC1    $f0  , FPU_OFFSET_REG(0)(A0)                                ;/*  ���� FPU ż����żĴ���     */
    SDC1    $f2  , FPU_OFFSET_REG(2)(A0)
    SDC1    $f4  , FPU_OFFSET_REG(4)(A0)
    SDC1    $f6  , FPU_OFFSET_REG(6)(A0)
    SDC1    $f8  , FPU_OFFSET_REG(8)(A0)
    SDC1    $f10 , FPU_OFFSET_REG(10)(A0)
    SDC1    $f12 , FPU_OFFSET_REG(12)(A0)
    SDC1    $f14 , FPU_OFFSET_REG(14)(A0)
    SDC1    $f16 , FPU_OFFSET_REG(16)(A0)
    SDC1    $f18 , FPU_OFFSET_REG(18)(A0)
    SDC1    $f20 , FPU_OFFSET_REG(20)(A0)
    SDC1    $f22 , FPU_OFFSET_REG(22)(A0)
    SDC1    $f24 , FPU_OFFSET_REG(24)(A0)
    SDC1    $f26 , FPU_OFFSET_REG(26)(A0)
    SDC1    $f28 , FPU_OFFSET_REG(28)(A0)
    SDC1    $f30 , FPU_OFFSET_REG(30)(A0)

    SW      T1   , FPU_OFFSET_FCSR(A0)                                 ;/*  ���� FPU ״̬�Ĵ���         */

    EHB

    JR      RA
    NOP
    FUNC_END(mipsVfp32Save)

;/*********************************************************************************************************
;  �ָ� FPU �Ĵ���
;*********************************************************************************************************/

FUNC_DEF(mipsVfp32Restore)
    ENABLE_FPU                                                          ;/*  ʹ�� FPU                    */

    LW      T1   , FPU_OFFSET_FCSR(A0)

#if LW_CFG_CPU_WORD_LENGHT == 64
    LDC1    $f1  , FPU_OFFSET_REG(1)(A0)                                ;/*  �ָ� FPU ������żĴ���     */
    LDC1    $f3  , FPU_OFFSET_REG(3)(A0)
    LDC1    $f5  , FPU_OFFSET_REG(5)(A0)
    LDC1    $f7  , FPU_OFFSET_REG(7)(A0)
    LDC1    $f9  , FPU_OFFSET_REG(9)(A0)
    LDC1    $f11 , FPU_OFFSET_REG(11)(A0)
    LDC1    $f13 , FPU_OFFSET_REG(13)(A0)
    LDC1    $f15 , FPU_OFFSET_REG(15)(A0)
    LDC1    $f17 , FPU_OFFSET_REG(17)(A0)
    LDC1    $f19 , FPU_OFFSET_REG(19)(A0)
    LDC1    $f21 , FPU_OFFSET_REG(21)(A0)
    LDC1    $f23 , FPU_OFFSET_REG(23)(A0)
    LDC1    $f25 , FPU_OFFSET_REG(25)(A0)
    LDC1    $f27 , FPU_OFFSET_REG(27)(A0)
    LDC1    $f29 , FPU_OFFSET_REG(29)(A0)
    LDC1    $f31 , FPU_OFFSET_REG(31)(A0)
#endif

    LDC1    $f0  , FPU_OFFSET_REG(0)(A0)                                ;/*  �ָ� FPU ż����żĴ���     */
    LDC1    $f2  , FPU_OFFSET_REG(2)(A0)
    LDC1    $f4  , FPU_OFFSET_REG(4)(A0)
    LDC1    $f6  , FPU_OFFSET_REG(6)(A0)
    LDC1    $f8  , FPU_OFFSET_REG(8)(A0)
    LDC1    $f10 , FPU_OFFSET_REG(10)(A0)
    LDC1    $f12 , FPU_OFFSET_REG(12)(A0)
    LDC1    $f14 , FPU_OFFSET_REG(14)(A0)
    LDC1    $f16 , FPU_OFFSET_REG(16)(A0)
    LDC1    $f18 , FPU_OFFSET_REG(18)(A0)
    LDC1    $f20 , FPU_OFFSET_REG(20)(A0)
    LDC1    $f22 , FPU_OFFSET_REG(22)(A0)
    LDC1    $f24 , FPU_OFFSET_REG(24)(A0)
    LDC1    $f26 , FPU_OFFSET_REG(26)(A0)
    LDC1    $f28 , FPU_OFFSET_REG(28)(A0)
    LDC1    $f30 , FPU_OFFSET_REG(30)(A0)

    CTC1_EHB(T1, CP1_STATUS)                                            ;/*  �ָ� FPU ״̬�Ĵ���         */

    JR      RA
    NOP
    FUNC_END(mipsVfp32Restore)

;/*********************************************************************************************************
;  ��� FIR �Ĵ���
;*********************************************************************************************************/

FUNC_DEF(mipsVfp32GetFIR)
    MFC0_EHB(T1, CP0_STATUS)                                            ;/*  T1 = ԭ FPU ����״̬        */

    ENABLE_FPU                                                          ;/*  ʹ�� FPU                    */

    CFC1_EHB(V0, CP1_REVISION)                                          ;/*  V0 = CP1_REVISION           */

    MTC0_EHB(T1, CP0_STATUS)                                            ;/*  �ָ�ԭ FPU ����״̬         */
    JR      RA
    NOP
    FUNC_END(mipsVfp32GetFIR)

;/*********************************************************************************************************
;  ��� FCSR �Ĵ���
;*********************************************************************************************************/

FUNC_DEF(mipsVfp32GetFCSR)
    MFC0_EHB(T1, CP0_STATUS)                                            ;/*  T1 = ԭ FPU ����״̬        */

    ENABLE_FPU                                                          ;/*  ʹ�� FPU                    */

    CFC1_EHB(V0, CP1_STATUS)                                            ;/*  V0 = CP1_STATUS             */

    MTC0_EHB(T1, CP0_STATUS)                                            ;/*  �ָ�ԭ FPU ����״̬         */
    JR      RA
    NOP
    FUNC_END(mipsVfp32GetFCSR)

;/*********************************************************************************************************
;  ���� FCSR �Ĵ���
;*********************************************************************************************************/

FUNC_DEF(mipsVfp32SetFCSR)
    MFC0_EHB(T1, CP0_STATUS)                                            ;/*  T1 = ԭ FPU ����״̬        */

    ENABLE_FPU                                                          ;/*  ʹ�� FPU                    */

    CTC1_EHB(A0, CP1_STATUS)                                            ;/*  CP1_STATUS = A0             */

    MTC0_EHB(T1, CP0_STATUS)                                            ;/*  �ָ�ԭ FPU ����״̬         */
    JR      RA
    NOP
    FUNC_END(mipsVfp32SetFCSR)

    FILE_END()

#endif
;/*********************************************************************************************************
;  END
;*********************************************************************************************************/