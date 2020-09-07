---
layout: simple_layout
title: "New State Vector"
---

# Create a new stateVector

To initialize a new state vector, use:
```matlab
sv = stateVector;
```

This will create an empty state vector. We can now start adding variables to the vector.

### Optional: Name the state vector.

You can give the state vector an identifying name by providing a string as the first input to the "stateVector" method. For example:
```matlab
sv = stateVector('NH Surface Temperature');
```
will create a state vector named "NH Surface Temperature". You can get the name of a stateVector via:
```
sv.name
```
If you want to change the name of a state vector, you can also [rename](rename) it later.

### Optional: Disable console output

By default, state vectors will print notification messages to the console when certain design choices are made. You can use the second input to stateVector to specify whether to notify the console. Use false to disable this output, as per:
```matlab
sv = stateVector('My name', false);
```

[Previous](intro)   [Next](concepts)
