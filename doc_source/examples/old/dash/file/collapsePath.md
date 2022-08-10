# Collapse . and .. entries

Any "." entries on a file path are removed

```in
mypath = './has/./on/./path';
path = dash.file.collapsePath(mypath)
```

```out
path =
      'has/on/path'
```

Any ".." entries are removed along with their associate subfolders:

```in
mypath = 'a/path/with/../and/nested/../../entries';
path = dash.file.collapsePath(mypath)
```

```out
path = 
      'a/path/entries'
```

Combination of both . and .. entries:

```in
mypath = 'path/to/folder/then/./../../relative/file/path.txt';
path = dash.file.collapsePath(mypath)
```

```out
path = 
      'path/to/relative/file/path.txt'
```
  