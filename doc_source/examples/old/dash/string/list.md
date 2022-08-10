# Lists with 1, 2, or 3+ elements

With one element:

```in
list = dash.string.list("value1")
```

```out
list =
      "value1"
```

With 2 elements

```in
list = dash.string.list(["value1", "value2"])
```

```out
list = 
      "value1 and value2"
```

With 3+ elements:

```in
list = dash.string.list(["v1","v2","v3","v4"])
````

```out
list = 
      "v1, v2, v3, and v4"
```

# Lists of integers

```in
list = dash.string.list([1 2 3 4 5])
```

```out
list =
      "1, 2, 3, 4, and 5"
```