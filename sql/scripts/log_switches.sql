SELECT * FROM (
SELECT * FROM (
SELECT   TO_CHAR(FIRST_TIME, 'DD/MM') AS "DAY"
       , to_char(SUM(DECODE(TO_CHAR(FIRST_TIME, 'HH24'), '00', 1, 0)), '999') "00:00"
       , to_char(SUM(DECODE(TO_CHAR(FIRST_TIME, 'HH24'), '01', 1, 0)), '999') "01:00"
       , to_char(SUM(DECODE(TO_CHAR(FIRST_TIME, 'HH24'), '02', 1, 0)), '999') "02:00"
       , to_char(SUM(DECODE(TO_CHAR(FIRST_TIME, 'HH24'), '03', 1, 0)), '999') "03:00"
       , to_char(SUM(DECODE(TO_CHAR(FIRST_TIME, 'HH24'), '04', 1, 0)), '999') "04:00"
       , to_char(SUM(DECODE(TO_CHAR(FIRST_TIME, 'HH24'), '05', 1, 0)), '999') "05:00"
       , to_char(SUM(DECODE(TO_CHAR(FIRST_TIME, 'HH24'), '06', 1, 0)), '999') "06:00"
       , to_char(SUM(DECODE(TO_CHAR(FIRST_TIME, 'HH24'), '07', 1, 0)), '999') "07:00"
       , to_char(SUM(DECODE(TO_CHAR(FIRST_TIME, 'HH24'), '08', 1, 0)), '999') "08:00"
       , to_char(SUM(DECODE(TO_CHAR(FIRST_TIME, 'HH24'), '09', 1, 0)), '999') "09:00"
       , to_char(SUM(DECODE(TO_CHAR(FIRST_TIME, 'HH24'), '10', 1, 0)), '999') "10:00"
       , to_char(SUM(DECODE(TO_CHAR(FIRST_TIME, 'HH24'), '11', 1, 0)), '999') "11:00"
       , to_char(SUM(DECODE(TO_CHAR(FIRST_TIME, 'HH24'), '12', 1, 0)), '999') "12:00"
       , to_char(SUM(DECODE(TO_CHAR(FIRST_TIME, 'HH24'), '13', 1, 0)), '999') "13:00"
       , to_char(SUM(DECODE(TO_CHAR(FIRST_TIME, 'HH24'), '14', 1, 0)), '999') "14:00"
       , to_char(SUM(DECODE(TO_CHAR(FIRST_TIME, 'HH24'), '15', 1, 0)), '999') "15:00"
       , to_char(SUM(DECODE(TO_CHAR(FIRST_TIME, 'HH24'), '16', 1, 0)), '999') "16:00"
       , to_char(SUM(DECODE(TO_CHAR(FIRST_TIME, 'HH24'), '17', 1, 0)), '999') "17:00"
       , to_char(SUM(DECODE(TO_CHAR(FIRST_TIME, 'HH24'), '18', 1, 0)), '999') "18:00"
       , to_char(SUM(DECODE(TO_CHAR(FIRST_TIME, 'HH24'), '19', 1, 0)), '999') "19:00"
       , to_char(SUM(DECODE(TO_CHAR(FIRST_TIME, 'HH24'), '20', 1, 0)), '999') "20:00"
       , to_char(SUM(DECODE(TO_CHAR(FIRST_TIME, 'HH24'), '21', 1, 0)), '999') "21:00"
       , to_char(SUM(DECODE(TO_CHAR(FIRST_TIME, 'HH24'), '22', 1, 0)), '999') "22:00"
       , to_char(SUM(DECODE(TO_CHAR(FIRST_TIME, 'HH24'), '23', 1, 0)), '999') "23:00"
    FROM V$LOG_HISTORY
    WHERE extract(year FROM FIRST_TIME) = extract(year FROM sysdate)
GROUP BY TO_CHAR(FIRST_TIME, 'DD/MM')
) ORDER BY TO_DATE(extract(year FROM sysdate) || DAY, 'YYYY DD/MM') DESC
) WHERE ROWNUM < 8
