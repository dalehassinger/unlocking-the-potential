# State file for Windows Services
# This state can be changed to work with any Windows Service
# Change the name to match the service name you want to use
# Example on how to run state.apply from cli
# salt "WIN-19-001" state.apply states.spooler

# Stop a Windows Service
stop_service:
  service.dead:
    - name: spooler

# Start a Windows Service and Startup will be Automatic   
Start_service:
  service.running:
    - enable: True
    - name: spooler

# Disable a Windows Service    
disable_service:
  service.disabled:
    - name: spooler
    