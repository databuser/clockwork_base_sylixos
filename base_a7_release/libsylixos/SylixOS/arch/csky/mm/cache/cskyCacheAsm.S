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
;** ��   ��   ��: cskyCacheAsm.S
;**
;** ��   ��   ��: Hui.Kai (�ݿ�)
;**
;** �ļ���������: 2015 �� 12 �� 01 ��
;**
;** ��        ��: C-SKY ��ϵ���� CACHE ����.
;*********************************************************************************************************/

#ifndef ASSEMBLY
#define ASSEMBLY 1
#endif

#include <arch/assembler.h>
#include <arch/csky/arch_def.h>
#include <config/kernel/cache_cfg.h>
#include <config/cpu/cpu_cfg_csky.h>

#if !defined(__SYLIXOS_CSKY_ARCH_CK803__)

#if LW_CFG_CACHE_EN > 0

    EXPORT_LABEL(cskyICacheInvalidateAll)
    EXPORT_LABEL(cskyICacheEnableHw)
    EXPORT_LABEL(cskyICacheDisableHw)

    EXPORT_LABEL(cskyDCacheInvalidateAll)
    EXPORT_LABEL(cskyDCacheClearAll)
    EXPORT_LABEL(cskyDCacheFlushAll)
    EXPORT_LABEL(cskyDCacheDisableHw)
    EXPORT_LABEL(cskyDCacheEnableHw)

    EXPORT_LABEL(cskyBranchPredictorInvalidate)
    EXPORT_LABEL(cskyBranchPredictionEnable)
    EXPORT_LABEL(cskyBranchPredictionDisable)

    FILE_BEGIN()

;/*********************************************************************************************************
;  ��Ч���� ICACHE
;*********************************************************************************************************/

FUNC_DEF(cskyICacheInvalidateAll)
    MOVI        A0 , B_CFR_CACHE_I | M_CFR_INV
    MTCR        A0 , CR17
    RTS
    FUNC_END(cskyICacheInvalidateAll)

;/*********************************************************************************************************
;  ��Ч���� DCACHE
;*********************************************************************************************************/

FUNC_DEF(cskyDCacheInvalidateAll)
    MOVI        A0 , B_CFR_CACHE_D | M_CFR_INV
    MTCR        A0 , CR17
    RTS
    FUNC_END(cskyDCacheInvalidateAll)

;/*********************************************************************************************************
;  CLEAR ���� DCACHE
;*********************************************************************************************************/

FUNC_DEF(cskyDCacheClearAll)
    MOVI        A0 , B_CFR_CACHE_D | M_CFR_CLR | M_CFR_INV
    MTCR        A0 , CR17
    RTS
    FUNC_END(cskyDCacheClearAll)

;/*********************************************************************************************************
;  FLUSH ���� DCACHE
;*********************************************************************************************************/

FUNC_DEF(cskyDCacheFlushAll)
    MOVI        A0 , B_CFR_CACHE_D | M_CFR_CLR
    MTCR        A0 , CR17
    RTS
    FUNC_END(cskyDCacheFlushAll)

;/*********************************************************************************************************
;  ���� ICACHE
;*********************************************************************************************************/

FUNC_DEF(cskyICacheDisableHw)
    MOVI        A0 , B_CFR_CACHE_I | M_CFR_INV
    MTCR        A0 , CR17

    MFCR        A0 , CR18
    BCLRI       A0 , 2
    MTCR        A0 , CR18
    RTS
    FUNC_END(cskyICacheDisableHw)

;/*********************************************************************************************************
;  ���� DCACHE
;*********************************************************************************************************/

FUNC_DEF(cskyDCacheDisableHw)
    MOVI        A0 , B_CFR_CACHE_D | M_CFR_CLR | M_CFR_INV
    MTCR        A0 , CR17

    MFCR        A0 , CR18
    BCLRI       A0 , 3
    MTCR        A0 , CR18
    RTS
    FUNC_END(cskyDCacheDisableHw)

;/*********************************************************************************************************
;  ʹ�� ICACHE
;*********************************************************************************************************/

FUNC_DEF(cskyICacheEnableHw)
    MOVI        A0 , B_CFR_CACHE_I | M_CFR_INV
    MTCR        A0 , CR17

    MFCR        A0 , CR18
    BSETI       A0 , 2
    MTCR        A0 , CR18
    RTS
    FUNC_END(cskyICacheEnableHw)

;/*********************************************************************************************************
;  ʹ�� DCACHE
;*********************************************************************************************************/

FUNC_DEF(cskyDCacheEnableHw)
    MOVI        A1 , B_CFR_CACHE_D | M_CFR_CLR | M_CFR_INV
    MTCR        A1 , CR17

    MFCR        A1 , CR18
    BSETI       A1 , 3                                                  ;/*  DE ���ݸ��ٻ�������λ       */

    BCLRI       A1 , S_CACHE_CFG_WB                                     ;/*  WB ���ٻ���д������λ       */
    BCLRI       A1 , S_CACHE_CFG_WA                                     ;/*  WA ���ٻ���д������Ч����   */
    OR          A1 , A0

    MTCR        A1 , CR18
    RTS
    FUNC_END(cskyDCacheEnableHw)

;/*********************************************************************************************************
;  ��Ч��֧Ԥ�⻺��
;*********************************************************************************************************/

FUNC_DEF(cskyBranchPredictorInvalidate)
    MFCR        A0 , CR17
    BSETI       A0 , 16
    BSETI       A0 , 17
    MTCR        A0 , CR17
    RTS
    FUNC_END(cskyBranchPredictorInvalidate)

;/*********************************************************************************************************
;  ʹ�ܷ�֧Ԥ��
;*********************************************************************************************************/

FUNC_DEF(cskyBranchPredictionEnable)
    MOVIH       A0 , 0x3                                                ;/*  ��Ч��֧Ԥ�⻺��            */
    MTCR        A0 , CR17

    MFCR        A0 , CR18
    BSETI       A0 , 11                                                 ;/*  BTB ��֧Ŀ�껺����ʹ��      */
    BSETI       A0 , 6                                                  ;/*  Z ����Ԥ����ת����λ        */
    BSETI       A0 , 5                                                  ;/*  RS ��ַ����ջ����λ         */
    MTCR        A0 , CR18
    RTS
    FUNC_END(cskyBranchPredictionEnable)

;/*********************************************************************************************************
;  �رշ�֧Ԥ��
;*********************************************************************************************************/

FUNC_DEF(cskyBranchPredictionDisable)
    MOVIH       A0 , 0x3                                                ;/*  ��Ч��֧Ԥ�⻺��            */
    MTCR        A0 , CR17

    MFCR        A0 , CR18
    BCLRI       A0 , 11
#ifndef __CK807__
    BCLRI       A0 , 6
#endif
    BCLRI       A0 , 5
    MTCR        A0 , CR18
    RTS
    FUNC_END(cskyBranchPredictionDisable)

    FILE_END()

#endif
#endif
;/*********************************************************************************************************
;  END
;*********************************************************************************************************/