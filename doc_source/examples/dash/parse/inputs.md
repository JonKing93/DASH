# Parse a set of optional inputs

Specify a set of input flags and associated default values

```
flags = ["plus", "times", "overwrite"];
defaults = {0, 1, true};
```

Parse inputs for a function with 3 required inputs and subsequent optional inputs:

```in
nPrevious = 3;
varargout = {"times", 5, 'overwrite', false};

[plus, times, overwrite] = parse.inputs(varargout, flags, defaults, nPrevious)
```

```out
plus =
      0
      
times =
       5
       
overwrite = 
           false
```

The "times" and "overwrite" variables have been set to the user-specified values of 5 and false. The "plus" flag was not set, and thus is set to the default value of 0.

Examine the parsed values. 

```
