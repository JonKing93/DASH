# Assert that a file exists

A file that passes the assertion:

```
filename = "a-file-that-exists.mat";
dash.assert.fileExists(filename)

filename = "path/to/a-file-that-exists.mat";
dash.assert.fileExists(filename)
```

Files that fail the assertion:

```in
filename = "not-a-real-file.mat";
dash.assert.fileExists(filename)
```

```error
File "not-a-real-file.mat" could not be found. It may be misspelled or not on the active path.
```


# Include default file extension

Look at the extension of a file on the active path:

```in
dir
```

```out
.      ..      myFile.mat
```

We can see that "myFile" has a ".mat" extension.

Provide the file name and default extension:

```
dash.assert.fileExists("myFile", ".mat")
```

The assertion passes.


# Customize error message

Customize error messages so they appear to originate from the calling function:

```in
file = "not-a-file.mat";
idHeader = "my:error:header";
dash.assert.fileExists(file, [], idHeader);
```

```error
File "not-a-file.mat" could not be found. It may be misspelled or not on the active path."
```

Examine the error ID:

```in
ME = lasterror;
ID = ME.identifier
```

```out
ID =
    'my:error:header:fileNotFound'
```


# Return absolute file path

Look for files on the active path:

``in
dir
```

```out
.    ..    myFolder
```

Look for files in the folder:

```in
dir myFolder
```

```out
.   ..   myFile.txt
```

We can see the file "myFile.txt" is located in the folder named "myFolder". If we assert that myFile.txt exists using only the filename, the function returns the full path to the file:

```in
file = "myFile.txt";
fullpath = dash.assert.fileExists(file)
```

```out
fullpath =
          "myFolder/myFile.txt"
```



# Customize error message

Customize the error message so it appears to originate from the calling function:

```in
file = "not-a-real-file.m";
dash.assert.fileExists(file,