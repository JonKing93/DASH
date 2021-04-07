---
layout: simple_layout
title: "New State Vector"
---

# Create a new stateVector

To initialize a new state vector, use:
```matlab
sv = stateVector;
```

This will create an empty state vector. We can now start adding variables to the vector. For the rest of this tutorial, we will use "sv" to refer to a stateVector object. However, feel free to use a different naming convention in your own code.

<br>
### Optional: Name the state vector.

You can give the state vector an identifying name by providing a string as the first input. For example:
```matlab
sv = stateVector('NH Surface Temperature');
```
will create a state vector named "NH Surface Temperature". You can get the name of a stateVector via:
```matlab
sv.name
```
If you want to change the name of a state vector, you can also [rename](rename#rename-a-state-vector) it later.

<br>
### Optional: Disable console output

By default, state vectors will print notification messages to the console when certain design choices are made. You can use the second input to stateVector to specify whether to provide these notification. Use false to disable notifications, as per:
```matlab
sv = stateVector('My name', false);
```
If you change your mind, you can also [enable/disable notifications](notify-console) later.

[Previous](dimension-indices)---[Next](add)
