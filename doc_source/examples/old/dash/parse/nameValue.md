# Parse a set of optional inputs

Specify a set of input Name,Value flags and associated default values

```
flags = ["plus", "times", "overwrite"];
defaults = {0, 1, true};
```

Parse user-provided inputs. Here, the user provided values for the "times" and "overwrite" flags, but not for "plus".

```in
nPrevious = 3;
varargin = {"times", 5, 'overwrite', false};

[plus, times, overwrite] = dash.parse.nameValue(varargout, flags, defaults)
```

```out
plus =
      0
      
times =
       5
       
overwrite = 
           false
```

The "times" and "overwrite" variables have been set to the user-specified values of 5 and false. The "plus" flag was not set by the user, and thus is set to the default value of 0.


# Unrecognized option names

Throw an error if the user inputs an unrecognized flag option:

```in
flags = ["plus", "times", "overwrite"];
defaults = {0, 1, true};
varargin = {'times', 5, 'not-a-flag', 5};

dash.parse.nameValue(varargin, flags, defaults);
```

```error
Option name 2 ("not-a-flag") is not a recognized option name.
```


# Customize the error message

Include information about the number of inputs preceding the optional arguments, and also provide a custom error ID:

```in
flags = ["plus", "times", "overwrite"];
defaults = {0, 1, true};
varargin = {'times', 5, 7};

nPrevious = 3;
header = "my:header";

dash.parse.nameValue(varargin, flags, defaults, nPrevious, header);
```

```error
You must provide an even number of inputs after the first 3 arguments
```

Also examine the error ID:

```in
ME = lasterror;
ID = ME.identifier
```

```out
ID = 
    'my:header'
```