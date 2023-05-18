### VMware Aria Operations | Metric Search Examples


```
# --- Show Hosts with High CPU Usage
Metric: Host System where CPU|Usage % > 80

# --- Show Hosts with High Memory Usage
Metric: Host System where Memory|Usage % > 80

# --- Show Hosts In Maintenance Mode
Metric: Host System where Runtime|Maintenance State equals 'inMaintenance'

# --- Show Hosts where Health is less than 100%
Metric: Host System where Badge|Health % < 100

# --- Show Hosts where Workload is greater than 75%
Metric: Host System where Badge|Workload % > 75

# --- Show CPU Usage and Memory Usage for all Hosts In a Specific Cluster
Metric: Host System where CPU|Usage % > 0 and Memory|Usage % > 0 and Summary|Parent Cluster equals 'Cluster-01'
```
