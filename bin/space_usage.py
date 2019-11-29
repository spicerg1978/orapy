#!/bin/env python

##################################################################################################
#  Name:        space_usage.py                                                                   #
#  Author:      Gareth Spicer                                                                    #
#  Description: Prints tablespace usage for oracle database                                      #
#                                                                                                #
#  Usage: space_usage                                                                            #
#                                                                                                #
# History:                                                                                       #
#                                                                                                #
# Date       Ver. Who              Change Description                                            #
# ---------- ---- ---------------- ------------------------------------------------------------- #
# 18/11/2019 1.00 Gareth Spicer    Initial script                                                #
# 18/11/2019 1.01 Gareth Spicer	   Amended to use sql file and read                              #
# 19/11/2019 1.02 Gareth Spicer    Amended to make use of oracle wallet for db connection	 #
##################################################################################################
from __future__ import print_function

import cx_Oracle
import pandas as pd
import sys

# comment out for debug
sys.tracebacklimit = 0

# Open SQL file
# Should add a check to see if SQL file exists 
fd = open('../sql/space_usage.sql','r')
sqlFile = fd.read()
fd.close

# Using oracle wallet for connection so just ORACLE_SID passed in
try: 
    conn = cx_Oracle.connect(dsn="orcl")
except cx_Oracle.DatabaseError as exc:
    err, = exc.args
    print("Please check your credentials.\n")
    print("Oracle Error:", err.message)
    exit()

cur = conn.cursor()

try:
    cur.execute(sqlFile)
except cx_Oracle.DatabaseError as exc:
    error, = exc.args
    print("Oracle-Error-Code:", error.code)
    print("Oracle-Error-Message:", error.message)
    exit()

results = cur.fetchall()
tb_usage = pd.DataFrame(results, columns=['Tablespace','Type','Extent','Size MB','Free MB','Used MB','Status'])

cur.close()
conn.close()

# Output Tablespace Results
print("#################################################################")
print("\t\t\tTablespace Usage Report:")
print("#################################################################")
print(tb_usage)
print("#################################################################")



    
