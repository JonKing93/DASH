# Parse flags from varargin

Collect option flags from varargin:

```in
varargin = {'flag1', "flag2", 'option3'};
flags = dash.parse.vararginFlags(varargin)
```

```out
flags =
       "flag1"
       "flag2"
       "option3"
```

The flags are all converted to strings and organized in a vector


# Throw error if not a flag

If an input is not a strflag, throw an error:

```in
varargin = {'flag1', 5, "option3"};
flags = dash.parse.vararginFlags(varargin);
```

```error
Input 2 must be a string scalar or character row vector
```


# Parse flags with interval spacing

By default, the function requires every element of varargin to be a strflag. However, you can use the second input to specify a spacing between flags. This is often useful for Name,Value input pairs.

```in
varargin = {'flag1', 1, "option2", false};
spacing = 2;

flags = dash.parse.vararginFlags(varargin, spacing)
```

```out
flags =
       "flag1"
       "option2"
```

# Customize error

You can customize error message to include information about the number of arguments preceding optional varargin inputs. You can also customize the error ID:

```in
varargin = {'flag1', 5};
spacing = 1;

nPrevious = 4;
header = "my:header";

flags = dash.parse.vararginFlags(varargin, spacing, nPrevious, header)
```

```error
Input 6 must be a string scalar or character row vector
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