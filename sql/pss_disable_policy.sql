BEGIN
DBMS_RLS.ENABLE_POLICY('CONNECTUSER10_APP', 'HALF_TRADE', 'AS_VPD_POLICY',FALSE);
DBMS_RLS.ENABLE_POLICY('CONNECTUSER10_APP', 'TRADE_INFO', 'VPD_COMPONENT',FALSE);
DBMS_RLS.ENABLE_POLICY('CONNECTUSER10_APP', 'SLIP_IDS', 'AS_VPD_POLICY',FALSE);
END;
/

