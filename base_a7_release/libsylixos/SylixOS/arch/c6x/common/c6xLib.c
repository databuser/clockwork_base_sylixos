/*********************************************************************************************************
**
**                                    �й�������Դ��֯
**
**                                   Ƕ��ʽʵʱ����ϵͳ
**
**                                SylixOS(TM)  LW : long wing
**
**                               Copyright All Rights Reserved
**
**--------------�ļ���Ϣ--------------------------------------------------------------------------------
**
** ��   ��   ��: c6xLib.c
**
** ��   ��   ��: Jiao.JinXing (������)
**
** �ļ���������: 2017 �� 03 �� 17 ��
**
** ��        ��: c6x ��ϵ�����ڲ���.
*********************************************************************************************************/
#define  __SYLIXOS_KERNEL
#include "SylixOS.h"
#include "stdlib.h"
/*********************************************************************************************************
** ��������: archPageCopy
** ��������: ����һ��ҳ��
** �䡡��  : pvTo      Ŀ��
**           pvFrom    Դ
** �䡡��  : NONE
** ȫ�ֱ���:
** ����ģ��:
*********************************************************************************************************/
VOID  archPageCopy (PVOID  pvTo, PVOID  pvFrom)
{
#if defined(_TMS320C6400_PLUS)
    archC64PlusMemcpy(pvTo, pvFrom, LW_CFG_VMM_PAGE_SIZE);
#else
    REGISTER INT      i;
    REGISTER UINT64  *pu64To   = (UINT64 *)pvTo;
    REGISTER UINT64  *pu64From = (UINT64 *)pvFrom;

    for (i = 0; i < (LW_CFG_VMM_PAGE_SIZE >> 3); i += 16) {
        *pu64To++ = *pu64From++;
        *pu64To++ = *pu64From++;
        *pu64To++ = *pu64From++;
        *pu64To++ = *pu64From++;
        *pu64To++ = *pu64From++;
        *pu64To++ = *pu64From++;
        *pu64To++ = *pu64From++;
        *pu64To++ = *pu64From++;
        *pu64To++ = *pu64From++;
        *pu64To++ = *pu64From++;
        *pu64To++ = *pu64From++;
        *pu64To++ = *pu64From++;
        *pu64To++ = *pu64From++;
        *pu64To++ = *pu64From++;
        *pu64To++ = *pu64From++;
        *pu64To++ = *pu64From++;
    }
#endif                                                                  /*  !defined(_TMS320C6400_PLUS) */
}
/*********************************************************************************************************
** ��������: archReboot
** ��������: ϵͳ��������
** �䡡��  : iRebootType       ��������
**           ulStartAddress    ������ʼ��ַ
** �䡡��  : NONE
** ȫ�ֱ���:
** ����ģ��:
*********************************************************************************************************/
VOID  archReboot (INT  iRebootType, addr_t  ulStartAddress)
{
    bspReboot(iRebootType, ulStartAddress);
}
/*********************************************************************************************************
  END
*********************************************************************************************************/