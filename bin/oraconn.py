#!/bin/env python

import cx_Oracle 

def gen_conn():
    global cur
    global conn
    conn = cx_Oracle.connect(dsn="orcl")
    cur = conn.cursor()

def cls_conn():
    global cur
    global conn
    cur.close()
    conn.close()

def exe_sql(SQL):
    cur.execute(SQL)
