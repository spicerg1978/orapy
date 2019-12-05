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
import oraconn
import pprint

# comment out for debug
sys.tracebacklimit = 0

def exec_script(*argv, **kwargs):
    # Using oracle wallet for connection so just ORACLE_SID passed in
    try: 
        oraconn.gen_conn()
    except cx_Oracle.DatabaseError as exc:
        err, = exc.args
        print("Please check your credentials.\n")
        print("Oracle Error:", err.message)
        exit()
    cur = oraconn.conn.cursor()
    #sqlfile = input("SQL Script to execute: ")
    if len(sys.argv) < 2:
        print('Atleast one command line argument required')
    sqlfile = sys.argv[1]
    # convert it to list
    #first_arg_list = list(first_arg)
    # filter it according to requirement 
    #first_arg_list_filtered = [ elem for elem in first_arg_list if elem not in '[],' ]
    try:
      # Open SQL file
      # Should add a check to see if SQL file exists 
      fd = open('/home/gareth/scripts/python/dbascripts/sql/' + sqlfile ,'r')
      sqlFile = fd.read()
      fd.close
      cur.execute(sqlFile)
    except cx_Oracle.DatabaseError as exc:
      error, = exc.args
      print("Oracle-Error-Code:", error.code)
      print("Oracle-Error-Message:", error.message)
      exit()
    col_names = []
    for i in range(0, len(cur.description)):
        col_names.append(cur.description[i][0])
    pp = pprint.PrettyPrinter(width=1024)
    pp.pprint(col_names)
    for result in cur:
        pp.pprint(result)
    cur.close()
    oraconn.cls_conn()

if __name__ == "__main__":
  exec_script()



    
