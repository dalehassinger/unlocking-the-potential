# State file for Windows Services

# Stop a Windows Service
stop_service:
  service.dead:
    - name: spooler

# Disable a Windows Service    
disable_service:
  service.disabled:
    - name: spooler
