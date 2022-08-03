# Return path to new file

Get the name for a new file in the current directory

```in
newFile = "my-file.mat";
here = pwd
```

```out
here =
      "path/to/location
```

Return the absolute path to the new file

```in
filename = dash.file.new(newFile)
```

```out
filename =
          "path/to/location/my-file.mat"
```


# Ensure file extension

Require the new file to have a specific extension:

```
extension = ".grid"
```

If the filename does not end with the extension, the extension is appended to the file name:

```in
newFile = "my-file";
filename = dash.file.new(newFile, extension)
```

```out
filename = 
          "path/to/here/myfile.grid"
```

If the new filename already ends with the extension, filename is not altered:

```in
newFile = "my-file.grid";
filename = dash.file.new(newFile, extension)
```

```out
filename = 
          "path/to/here/myfile.grid"
```


# Detect existing file

If the file already exists, throw an error:

```in
dir
```

```out
.    ..   a-file.mat
```

This folder holds a file named "a-file.mat". If we try to create a new file by the same name, the method throws an error:

```in
newFile = "a-file.mat"
dash.file.new(newFile)
```

```error
The file "a-file.mat" already exists.
```



# Overwrite existing file

Set the third input to true to allow existing files to be overwritten:

```in
dir
```

```out
.    ..   a-file.mat
```

This folder holds a file named "a-file.mat". We can overwrite this file by setting the third input to true:

```in
newFile = "a-file.mat"
overwrite = true;
filename = dash.file.new(newFile, [], true)
```

```error
filename = 
          "path/to/location/a-file.mat"
```


# Customize error

Use a custom error ID:

```in
header = "my:header";
newFile = "existing-file.mat";
overwrite = false;

filename = dash.file.new(newFile, [], overwrite, header)
```

```error
The file "existing-file.mat" already exists.
```

Examine the error ID:

```in
ME = lasterror;
ID = ME.identifier
```

```out
ID = 
    'my:header'
```