# Create new (empty) gridfile

Start by creating a gridMetadata object to define the scope of the gridded dataset. Here, we'll make an example metadata object for a gridded dataset spanning the globe at 1 degree resolution over the 1900s:

```
lat = (-90:90)';
lon = (1:360)';
time = (1900:2000)';
metadata = gridMetadata('lat', lat, 'lon', lon, 'time', time);
```

Also get the name for the new gridfile:

```
filename = 'my-file.grid';
```

Before creating the new .grid file, examine the contents of the current directory:

```in
dir
```

```out
.
..
```

The directory is currently empty. Now create the new .grid file and reexamine the contents of the directory:

```in
gridfile.new(filename, metadata)
dir
```

```out
.
..
my-file.grid
```


Note that the method will automatically add a ".grid" extension to the file name if missing. For example:

```in
file2 = 'a-second-file';
gridfile.new(file2, metadata);
dir
```

```out
.
..
my-file.grid
a-second-file.grid
```

The method has appended the ".grid" extension to the file name and created a new file named "a-second-file.grid".


# Overwrite existing file

By default, the method will not overwrite existing files. For example:

```in
dir
```

```out
.
..
my-file.grid
```

this directory already contains a file name "my-file.grid". Attempting to create a new .grid file with that name will cause an error:

```in
metadata = gridMetadata('site', (1:10)', 'time', (1900:2000)');
filename = "my-file.grid";
gridfile.new(filename, metadata);
```

```error
The file "my-file.grid" already exists.
```

You can disable the behavior and allow the method to overwrite files by setting the third input to true. For example:

```in
dir
```

```out
.
..
my-file.grid
```

the current directory contains a 





```
gridfile.new(filename, metadata, true)
```

The method no longer causes an error. 

