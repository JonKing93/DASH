# Test if string is URL

A string is considered a URL if it begins with http:// or https://

Strings that pass the test:

```in
myURL = 'http://some/web/page';
isurl = dash.is.url(myURL)

myURL2 = "https://some/web/page";
isurl = dash.is.url(myURL2)
```

```out
isurl =
       true
```

Strings that fail the test:

```in
string1 = 'here is some text that is not a URL';
isurl = dash.is.url(string1);

string2 = "text that contains https:// but does not begin with it"
isurl = dash.is.url(string2);
```

```out
isurl =
       false
```


