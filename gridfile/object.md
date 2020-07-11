---
layout: simple_layout
title: "Gridfile Objects"
---
# Create gridfile object

Now that we've created a .grid file, we'll want to start adding data sources to it. However, .grid files have a specialized format, so you don't want to read/write to them directly. Instead we'll create a gridfile object to interact with a particular file. Create a gridfile object using the gridfile command. For example,
```matlab
grid = gridfile.new('myfile.grid')
```
creates a gridfile object named grid that will allow us to interact with 'myfile.grid'.

Throughout the rest of this tutorial, I will use "grid" to refer to a gridfile object. However, feel free to use a different naming convention in your own code.

[Previous](\DASH\gridfile\new) [Next](\DASH\gridfile\add)
