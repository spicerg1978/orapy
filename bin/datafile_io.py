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
# 28/11/2019 1.02 Gareth Spicer    Added oraconn functions for database                          #
# 01/12/2019 1.03 Gareth Spicer    Testing commit into github					 #
#												 #
# TO DO:											 #
#	ADD DEBUG OPTION THAT CAN BE PASSED IN TO PRINT MORE INFO				 #
#       Sort out Date graph format 								 #
##################################################################################################

from __future__ import print_function
from pylab import *
import matplotlib.pyplot as plt
import matplotlib.dates as mdates
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

dtrg = input("Do you want to enter a date range (Y/N)?")
if dtrg in ('Y','y'):
   psql = 1
   stdt = input("Enter Start Date (YYYYMMDD):")
   eddt = input("Enter End Date (YYYYMMDD):")
# Need to add so a list of datafiles could be added
dfrg = input("Do you want to graph a file(s):(Y/N)?")
if dfrg in ('Y','y'):
   pfile = 1
   flnms = input("Enter Filename(s) (comma seperated):") 

oraconn.gen_conn()

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
else:
    # Connect using oracle wallet
    oraconn.cur.execute("""SELECT distinct file_name FROM file_io""")
    files = oraconn.cur.fetchall()

    i=1
    for file in files:
     if (i == len(files)):
       filelist = filelist + "'" + file[0] + "'"
       i += 1
     else:
       filelist = filelist + "'" + file[0] + "',"
       i += 1 

########################################################################
# Bug in oracle version 12.2, 18 + 19 
# Patch 25416731: TABLESPACE IO STATISTICS MISSING FROM AWR REPORT
# So need to apply patch for now I have mocked up some test data
########################################################################
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
#return SQL

oraconn.exe_sql(SQL)
records = oraconn.cur.fetchall() 
col = len(oraconn.cur.description)-1
columns = [column[0] for column in oraconn.cur.description]
oraconn.cls_conn()

#store date range from sql
created = [record[0] for record in records]
fig, ax = plt.subplots()
# plot graph
for x in range(0,col):
    x += 1
    dfile = [record[x] for record in records]
    ax.plot(created,dfile,label=columns[x])

fig.autofmt_xdate()
ax.fmt_xdata = mdates.DateFormatter('%Y-%m-%d')
ax.set_title('fig.autofmt_xdate fixes the labels')

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

