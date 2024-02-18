
---

**View Current Password Settings:**  
chage -l root  

---

**Change Password to never expire:**  
chage -I -1 -m 0 -M 99999 -E -1 root  

---

Sometimes it's annoying when Photon OS based appliances doesn't allow to use previously used password for **root** user. You may see the error 'Password has been already used. Choose another' when you try to use the password which was used earlier.  

By default, Photon OS remember last **Five** passwords. You can see the setting **‘remember=5’** in **/etc/pam.d/system-password**  

By changing ‘**remember** ‘ from **5** to **0** we can disable the remember password count and reset the root password.   

---

**Change password:**  
passwd  