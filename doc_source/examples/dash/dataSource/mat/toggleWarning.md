# Toggle warning state

Examine the initial warning state:

```in
warning('query', 'MATLAB:MatFile:OlderFormat')
```

```out
The state of warning 'MATLAB:MatFile:OlderFormat' is 'on'.
```

Change the warning state:

```in
resetState = dash.dataSource.mat.toggleWarning('error');
warning('query', 'MATLAB:MatFile:OlderFormat')
```

```out
The state of warning 'MATLAB:MatFile:OlderFormat' is 'error'.
```

Destroy the cleanup object to reset the warning state:

```in
clearvars resetState
warning('query', 'MATLAB:MatFile:OlderFormat')
```

```out
The state of warning 'MATLAB:MatFile:OlderFormat' is 'on'.
```