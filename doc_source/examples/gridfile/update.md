# Update a gridfile object

Create two gridfiles pointing to the same gridfile:

```
grid1 = gridfile('my-gridfile.grid');
grid2 = gridfile('my-gridfile.grid');
```

Alter the .grid file. Here, we'll change the fill value.

```in
fill = grid1.fillValue
```

```out
fill =
      NaN
```

```in
newFill = -999;
grid1.fillValue(newFill);
```

The second gridfile object has not been updated, so still reports the old fill value:

```in
fill2 = grid2.fillValue
```

```out
fill2 =
       NaN
```

Update the second gridfile to match the new values in the .grid file:

```in
grid2.update;
fill2 = grid2.fillValue
```

```out
fill2 =
       -999
```

