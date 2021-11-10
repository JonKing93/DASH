# Relative path to file from folder

When the file and folder are on the same drive, the functions returns the relative path from the folder to the file.

```in
myFile = 'C:\my\absolute\file\path.txt';
myFolder = 'C:\my\folder\path';

[path, isrelative] = dash.file.relativePath(myFile, myFolder)
```

```out
path = 
      '.\..\..\absolute\file\path.txt'
      
isrelative = 
            true
```

Note that returned relative paths always begin with the . location.

# File and folder on different drives

If the file and folder are located on different drives, then the function returns the absolute path to the file

```in
myFile = 'C:\my\file\path.txt';
myFolder = 'D:\folder\on\different\drive';

[path, isrelative] = dash.file.relativePath(myFile, myFolder)
```

```out
path =
      'C:\my\file\path.txt'
      
isrelative =
            false
```

Similarly, a local folder and web file:

```in
myFile = 'https://my/data/file.nc';
myFolder = 'C:\my\folder';

[path, isrelative] = dash.file.relativePath(myFile, myFolder)
```

```out
path = 
      'https://my/data/file.nc'
      
isrelative =
            false
```