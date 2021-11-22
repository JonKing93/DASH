# Check vector has no repeated elements

An example that passes the assertion:

```
noRepeats = ["a","vector","with","no","repeated","elements"];
dash.assert.uniqueSet(noRepeats);
```

An example that fails:

```in
hasRepeats = ["A","B","C","A"];
dash.assert.uniqueSet(hasRepeats);
```

```error
Value "A" is repeated multiple times. (Elements 1 and 4)
```

# Customize error message

```in
inputName = 'Option name';
header = "my:error:header";
hasRepeats = ["A","B","C","A"];

dash.assert.uniqueSet(hasRepeats, inputName, header);
```

```error
Option name "A" is repeated multiple times. (Elements 1 and 4)'
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
