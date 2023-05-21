# State file for Windows Services

stop_service:
  service.dead:
    - name: spooler
    
disable_service:
  service.disabled:
    - name: spooler
