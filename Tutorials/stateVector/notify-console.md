---
layout: simple_layout
title: Console Notifications
---

# Console notifications

By default, stateVector will print a notification message to the console when coupled variables are altered by a design decision. You can disable these messages using the "notifyConsole" method and using false as the first input
```matlab
sv = sv.notifyConsole( false )
```
To re-enable these messages, provide true as the first input
```matlab
sv = sv.notifyConsolse( true )
```
