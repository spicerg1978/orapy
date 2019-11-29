#!/bin/env python
##################################################################################################
#  Name:        graph_datafile_io.py                                                             #
#  Author:      Gareth Spicer                                                                    #
#  Description: Prints a graph of test io data fabricted for testing                             #
#                                                                                                #
#  Usage: graph_datafile_io                                                                      #
#                                                                                                #
# History:                                                                                       #
#                                                                                                #
# Date       Ver. Who              Change Description                                            #
# ---------- ---- ---------------- ------------------------------------------------------------- #
# 18/11/2019 1.00 Gareth Spicer    This is a example of using subplots in graph for testing      #
# 20/11/2019 1.01 Gareth Spicer    Add wallet connection method to script			 #
#                                  Dynamically set graph to collect all file info                #
# 25/11/2019 1.02 Gareth Spicer    Added functions to flow program				 #
# TO DO:											 #
#	ADD DEBUG OPTION THAT CAN BE PASSED IN TO PRINT MORE INFO				 #
##################################################################################################

from __future__ import print_function
from pylab import *
#import cx_Oracle
import matplotlib
import matplotlib.pyplot as plt
import numpy as np
import datetime
import oraconn 

# set variables that are needed
filelist = ''
psql = 0
pfile = 0
count = 0
files = ''
flnms = ''
SQL = ''

# create functions
def main():
    oraconn.gen_conn()
    generate_sql()
    exec_sql()
    close_conn()
    plot_graph()

#def gen_conn():
#    global cur
#    global conn
#    conn = cx_Oracle.connect(dsn="orcl")
#    cur = conn.cursor()

def close_conn():
    oraconn.cur.close()
    oraconn.conn.close()

def generate_sql():
    global SQL
    global files
    filelist = ''
    count = 0
    if pfile == 1:
      count = 0
      for i in flnms:
          if i == ',':
              count = count+1
      if count == 0:
        filelist = flnms
      else:
        my_files = tuple(flnms.split(","))
        filelist = my_files
        #print(filelist)
    else:
    # Connect using oracle wallet
      oraconn.cur.execute("""SELECT distinct file_name
                       FROM file_io""")
      files = oraconn.cur.fetchall()
    i=1
    for file in files:
     if (i == len(files)):
       filelist = filelist + "'" + file[0] + "'"
       i += 1
     else:
       filelist = filelist + "'" + file[0] + "',"
       i += 1 
    # Bug in oracle version 12.2, 18 + 19 
    # Patch 25416731: TABLESPACE IO STATISTICS MISSING FROM AWR REPORT
    # So need to apply patch for now I have mocked up some test data
    if psql == 1 and pfile == 0:
       SQL = "SELECT * FROM (SELECT to_char(created,'DD-MM-YYYY') created, file_name, io_wait FROM file_io WHERE TO_CHAR(created, 'yyyymmdd') BETWEEN " + stdt + " AND " + eddt + ") PIVOT (AVG(io_wait) FOR file_name IN (" + filelist + ")) ORDER BY 1"
    elif psql == 1 and pfile == 1 and count == 0:
       SQL = "SELECT * FROM (SELECT to_char(created,'DD-MM-YYYY') created, file_name, io_wait FROM file_io WHERE TO_CHAR(created, 'yyyymmdd') BETWEEN " + stdt + " AND " + eddt + ") PIVOT (AVG(io_wait) FOR file_name in ('" + str(filelist) + "')) ORDER BY 1"
    elif psql == 0 and pfile == 1 and count == 0:
       SQL = "SELECT * FROM (SELECT to_char(created,'DD-MM-YYYY') created, file_name, io_wait FROM file_io) PIVOT (AVG(io_wait) FOR file_name in ('" + str(filelist) + "')) ORDER BY 1"
    elif psql == 1 and pfile == 1 and count >= 1:
       SQL = "SELECT * FROM (SELECT to_char(created,'DD-MM-YYYY') created, file_name, io_wait FROM file_io WHERE TO_CHAR(created, 'yyyymmdd') BETWEEN " + stdt + " AND " + eddt + ") PIVOT (AVG(io_wait) FOR file_name in " + str(filelist) + ") ORDER BY 1"
    elif psql == 0 and pfile == 1 and count >= 1:
       SQL = "SELECT * FROM (SELECT created, file_name, io_wait FROM file_io) PIVOT (avg(io_wait) FOR file_name in " + str(filelist) + ") ORDER BY 1"
    else:
       SQL = "SELECT * FROM (SELECT created, file_name, io_wait FROM file_io) PIVOT (avg(io_wait) FOR file_name in (" + str(filelist) + ")) ORDER BY 1"
    return SQL
  
def exec_sql():
    global records
    global col 
    global columns
    oraconn.cur.execute(SQL)
    records = oraconn.cur.fetchall() 
    col = len(oraconn.cur.description)-1
    # print column headers
    columns = [column[0] for column in oraconn.cur.description]

def plot_graph():
    #store date range from sql
    created = [record[0] for record in records]
    # plot graph
    for x in range(0,col):
     x += 1
     dfile = [record[x] for record in records]
     plt.plot(created,dfile,label=columns[x])
    # print graph
    plt.title('Datafile IO Wait (ms)', color='b')
    plt.legend(loc='center right', bbox_to_anchor=(1.132, 0.5))
    if psql == 1:
     plt.xlabel('Date From: ' + stdt + ' To: ' + eddt, color='b')
    else:
     plt.xlabel('Date', color='b')
     plt.ylabel('IO (ms)', color='b')
    show()
    plt.show()

#Start Program
dtrg = input("Do you want to enter a date range (Y/N)?")
if dtrg in ('Y','y'):
   psql = 1
   stdt = input("Enter Start Date (YYYYMMDD):")
   eddt = input("Enter End Date (YYYYMMDD):")
dfrg = input("Do you want to graph all datafiles:(Y/N)?")
if dfrg in ('Y','y'):
   pfile = 1
   flnms = input("Enter Filename(s) (comma seperated):") 

main()

