# Console notifications

By default, stateVector will print a notification message to the console when coupled variables are altered by a design decision. You can disable these messages using the "notifyConsole" method and using false as the first input
```matlab
sv = sv.notifyConsole( false )
```
To re-enable these messages, provide true as the first input
```matlab
sv = sv.notifyConsolse( true )
```

Alternatively, you can disable notifications when you first create a state vector. (See [here](new#optional-disable-console-output) for a refresher.)
