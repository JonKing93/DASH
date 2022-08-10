# Print metadata object in console

Create an example gridMetadata object:

```
lat = -90:90;
lon = 0:359;
time = datetime(1,1,1):calyears(1):datetime(2000,1,1);
attributes = struct('Units', 'Kelvin', 'pressure', 1000);

meta = gridMetadata('lat', lat', 'lon', lon', 'time', time', 'attributes', attributes);
```

Print to console:

```in
meta.disp
```

```out
  gridMetadata with metadata:

           lon: [360×1 double]
           lat: [181×1 double]
          time: [2000×1 datetime]
    attributes: [1×1 struct]

  Show attributes
```