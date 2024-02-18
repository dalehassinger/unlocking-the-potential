
---

**vRA 8.x Shutdown:**  
 /opt/scripts/deploy.sh --onlyClean  

---

**vRA 8.x Start:**  
 /opt/scripts/deploy.sh  

---

**show vRA Status every 20 seconds:**  
watch -d -n 20 kubectl -n prelude get pods  

watch -d -n 10 kubectl get --all-namespaces pods  

---
 
**Check vRA Upgrade fail reasons:**  
vracli upgrade status --details  
