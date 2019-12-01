#!/bin/env python

##################################################################################################
#  Name:        unlock_user.py                                                                   #
#  Author:      Gareth Spicer                                                                    #
#  Description: Unlocks database users when they are locked                                      #
#                                                                                                #
#  Usage: unlock_user <user>                                                                     #
#                                                                                                #
# History:                                                                                       #
#                                                                                                #
# Date       Ver. Who              Change Description                                            #
# ---------- ---- ---------------- ------------------------------------------------------------- #
# 19/11/2019 1.00 Gareth Spicer    Initial script                                                #
#												 #
# To Do:											 #
#      Pass in user to unlock									 #
#      user SQL File to read SQL to execute						         #
#      Look into DDL error / warning when executed see if this can be done diffently	 	 #
##################################################################################################
from __future__ import print_function

import cx_Oracle
import sys

# comment out for debug
sys.tracebacklimit = 0

usr=sys.argv[1]

try: 
    # Using oracle wallet for connection so just ORACLE_SID passed in
    conn = cx_Oracle.connect(dsn="orcl")
except cx_Oracle.DatabaseError as exc:
    err, = exc.args
    print("Please check your credentials.\n")
    print("Oracle Error:", err.message)
    exit()

cur = conn.cursor()

SQL="select username, account_status from dba_users where username = upper(:ora_user)"

try:
    cur.execute(SQL, ora_user=usr)
except cx_Oracle.DatabaseError as exc:
    error, = exc.args
    print("Oracle-Error-Code:", error.code)
    print("Oracle-Error-Message:", error.message)
    exit()


for p_user, p_status in cur:
  print(p_user)
  print(p_status)
  if (p_status == 'OPEN'):
    print("Account is not locked")
  else:
    SQL="alter user " + usr + " account unlock"
    cur.execute(SQL)
    print("Account is unlocked")

cur.close()
conn.close()


    
