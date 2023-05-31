# Add registry values

reg_test1:
  reg.present:
    - name: 'HKEY_LOCAL_MACHINE\SYSTEM\vCROCS'
    - vname: DBH
    - vdata: TEST1
    - vtype: REG_SZ

reg_test2:
  reg.present:
    - name: 'HKEY_LOCAL_MACHINE\SYSTEM\vCROCS'
    - vname: INSTALL
    - vdata: TEST1
    - vtype: REG_SZ

reg_test3:
  reg.present:
    - name: 'HKEY_LOCAL_MACHINE\SYSTEM\vCROCS'
    - vname: Date
    - vdata: 05-31-2023
    - vtype: REG_SZ
