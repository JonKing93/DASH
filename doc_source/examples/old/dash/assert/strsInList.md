# Assert strings are members of a list

Example that passes the assertion:

```
list = ["here","is","an","example","list"];
strings = ["an", "here", "list"];

dash.assert.strsInList(strings, list)
```


Example that fails the assertion

```in
list = ["here","is","an","example","list"];
strings = ["different", "strings"];

dash.assert.strsInList(strings, list)
```

```error
Element 1 in strings ("different") is not a(n) value in the list. Allowed values are "here","is","an","example", and "list".
```

# Return indices of strings in the list

If the assert passes, the function returns the index of each string in the list:

```in
list = ["A","B","C","D","E"];
strings = ["C","A","B","B"];

indices = dash.assert.strsInList(strings, list)
```

```out
indices =
         [3     1     2     2]
```


# Customize error message

Customize the error message so it appears to originate from a calling function:

```in
stringsName = "my strings";
listName = "allowed list value";
idHeader = "my:error:header";

list = ["allowed","values"];
strings = ["not","in","the","list"];

dash.assert.strsInList(strings, list, stringsName, listName, idHeader)
```

```error
Element 1 of my strings ("not") is not a(n) allowed list value. Allowed values are "allowed", and "values"
```


