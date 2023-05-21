### VMware Aria Operations | Metric Search Examples

Check out this Blog Post that discusses Metric Searches:
[www.vCROCS.info | VMware Aria Operations Metric Search](https://www.vcrocs.info/unlocking-the-potential-vmware-aria-operations-metric-searching/)


```
# --- Find All VMs with CPU|Ready ms > 750 ms
Metric: Virtual Machine where CPU|Ready ms > 750 ms

# --- Find All VMs with CPU|Ready ms > 750 ms WHERE the host is esx-02a.corp.local
Metric: Virtual Machine where CPU|Ready ms > 750 ms childOf esx-02a.corp.local

# --- Find All VMs with CPU|Ready ms > 750 ms WHERE the cluster is Cluster-01
Metric: Virtual Machine where CPU|Ready ms > 750 ms childOf Cluster-01
```

---

```
# --- Find All VMs with CPU usage % greater than 90
Metric: Virtual Machine where CPU|Usage % > 90

# --- Find All VMs with Memory usage % greater than 90
Metric: Virtual Machine where Memory|Usage % > 90

# --- Find All VMs with Snap Shots older than 2 days
Metric: Virtual Machine where {Disk Space|Snapshot|Age (Days)} > 2

# --- Find All VMs running longer than 30 days. Shows VMs not patched if you do monthly patching.
Metric: Virtual Machine where {System|OS Uptime Second(s)} > 30 {Day(s)}

# --- Show CPU and Memory usage for all VMs with a specific string in the name
Metric: Virtual Machine where CPU|Usage % > 0 and Memory|Usage % > 0 and Configuration|Name contains 'rocky'

# --- Show CPU and Memory usage for a specific VM
Metric: Virtual Machine where CPU|Usage % > 0 and Memory|Usage % > 0 and Configuration|Name equals 'DBH-196'

# --- Show CPU and Memory usage for all VMs in a specific Cluster
Metric: Virtual Machine where CPU|Usage % > 0 and Memory|Usage % > 0 and Summary|Parent Cluster equals 'Cluster-02'
```

---

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

---

```
# --- Show Clusters where DRS was turned off
Metric: Cluster Configuration|DRS Configuration|Enabled of Cluster Compute Resource where Cluster Configuration|DRS Configuration|Enabled equals 'false'
```

---

```
# --- Show Datastores where Capacity used is greater than 75%
Metric: Datastore where Capacity|Used Space % > 75

# --- Show Datastores where Health is less than 100%
Metric: Datastore where Badge|Health % < 100
```