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
** ��   ��   ��: ar.h
**
** ��   ��   ��: Han.Hui (����)
**
** �ļ���������: 2009 �� 04 �� 02 ��
**
** ��        ��: ar �C archive ile format.
*********************************************************************************************************/

#ifndef __AR_H
#define	__AR_H

/*********************************************************************************************************
  Pre-4BSD archives had these magic numbers in them.
*********************************************************************************************************/
#define	OARMAG1	    0177555
#define	OARMAG2	    0177545

#define	ARMAG		"!<arch>\n"	                                        /* ar "magic number"            */
#define	SARMAG		8		                                            /* strlen(ARMAG);               */

#define	AR_EFMT1	"#1/"		                                        /* extended format #1           */

struct ar_hdr {
	char ar_name[16];		                                            /* name                         */
	char ar_date[12];		                                            /* modification time            */
	char ar_uid[6];			                                            /* user id                      */
	char ar_gid[6];			                                            /* group id                     */
	char ar_mode[8];		                                            /* octal file permissions       */
	char ar_size[10];		                                            /* size in bytes                */
#define	ARFMAG	"`\n"
	char ar_fmag[2];		                                            /* consistency check            */
};

#endif                                                                  /* __AR_H                       */
/*********************************************************************************************************
  END
*********************************************************************************************************/