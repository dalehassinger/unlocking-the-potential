# Add registry keys

reg_test1:
  reg.present:
    - name: 'HKEY_LOCAL_MACHINE\SYSTEM\vCROCS'
    - vname: vRA_Created
    - vdata: True
    - vtype: REG_SZ

reg_test2:
  reg.present:
    - name: 'HKEY_LOCAL_MACHINE\SYSTEM\vCROCS'
    - vname: INSTALL
    - vdata: 'Completed By: DBH'
    - vtype: REG_SZ

reg_test3:
  reg.present:
    - name: 'HKEY_LOCAL_MACHINE\SYSTEM\vCROCS'
    - vname: Date
    - vdata: 05-31-2023
    - vtype: REG_SZ

# remove a registry key
reg_test4:
  reg.absent:
    - name: 'HKEY_LOCAL_MACHINE\SYSTEM\vCROCS'
    - vname: DBH
