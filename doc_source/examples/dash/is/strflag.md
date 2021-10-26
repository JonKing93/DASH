# Test if input is strflag

When the input is a strflag:

```in
tf = dash.is.strflag('A char row vector')
tf = dash.is.strflag("A string scalar")
```

```out
tf =
    true
```

When the input is not a strflag:

```in
tf = dash.is.strflag(5)
tf = dash.is.strflag({'A cellstring'})
tf = dash.is.strflag(["A","string","vector"])
tf = dash.is.strflag(true)
```

```out
tf =
    false
```