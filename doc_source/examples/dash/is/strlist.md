# Test if input is strlist

When the input is a strlist:

```in
tf = dash.is.strlist('A char row vector')
tf = dash.is.strlist(["A","string","vector"])
tf = dash.is.strlist({'A', 'cellstring', 'vector'})
```

```out
tf = 
    true
```

When the input is not a strlist:

```in
tf = dash.is.strlist(5)
tf = dash.is.strlist(true)
tf = dash.is.strlist(["An","example";"string","matrix"])
```

```out
tf = 
    false
```