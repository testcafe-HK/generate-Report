@echo off
echo Parameter 1: %1
echo Parameter 2: %2
pause
/v1.0/users/@{variables('userId')}/onlineMeetings?$filter=JoinWebUrl%20eq%20'@{encodeUriComponent(variables('joinUrl'))}'
