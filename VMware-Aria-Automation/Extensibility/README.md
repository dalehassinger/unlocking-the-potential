#### VMware Aria Automation Extensibilty  

---

1. Subscription Condition Examples:  

---

Only run the subscription for a spefic Cloud Template:
```
event.data.blueprintId =='2249a7b7-5b45-42d4-8bbb-83d35f35c02b'
```

---

Subscription filter can include customProperties:
```
event.userName == 'youremail@domain.com' && event.data.customProperties.userInputProp == 'run'
```
