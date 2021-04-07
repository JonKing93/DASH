# Append state vectors

It can sometimes be useful to append two state vectors. This way, you can reuse previously designed variables in multiple vectors. To append a state vector to the current state vector use
```matlab
sv = sv.append( sv2 )
```
where sv2 is a second stateVector object. Note that, in order to append, the second state vector cannot share any variable names with the current state vector.
