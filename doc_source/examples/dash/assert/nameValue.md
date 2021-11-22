# Assert cell vector is of Name,Value pairs

An example that passes the assertion:

```
inputs = {'name1', 5, "name2", rand(4,4), 'name3', [false;false;true]};
dash.assert.nameValue(inputs)
```

An example that fails:

```in
inputs = {7, 5, false, true};
dash.assert.nameValue(inputs);
```

```error
Input 1 must be a string scalar or character row vector
```

# Return names and values

When the assertion passes, the function returns the names as a string vector, and the values as a cell vector:

```in
inputs = {'name1', 5, "name2", rand(4,4), 'name3', [false;false;true]};
[names, values] = dash.assert.nameValue(inputs)
```

```out
names = 
       "name1"
       "name2"
       "name3"
       
values =
        {[        5]}
        {4×4 double }
        {3×1 logical}
```

# Customize error messages

```in
nPrevious = 5;
extraInfo = 'Additional inputs must be option-name,option-value pairs';
header = 'my:error:header';

notValid = {'option1', 5, 'option2'};
dash.assert.nameValue(notValid, nPrevious, extraInfo, header);
```

```error
You must provide an even number of inputs after the first 5 inputs. (Additional inputs must be option-name,option-value pairs)
```

Also examine the error ID:

```in
ME = lasterror;
ID = ME.identifier
```

```out
ID = 
    'my:error:header'
```


