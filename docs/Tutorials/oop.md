### Object-oriented programming
DASH is written in a object-oriented style. But what does this mean?

In programming, you may be familiar with the concepts of variables and functions. For example, I might have a variable named "numbers":
```matlab
numbers = [1 2 4 9 3 8];
```
and a function named "mean" that can use "numbers" as an input:
```matlab
myAverage = mean(numbers);
```

Object oriented programming (OOP) is a technique that lets you combine specific functions and variables together. This can help organize code and ensure that functions are applied to the correct variables.


### So, how does this work?

In practice, OOP is similar to Matlab structures. If you are familiar with structures, you know that you can define fields for a structure. For example,
```matlab
myStructure = struct('numbers', [5 6 7], 'message', 'hello!');
```
will create a structure with a "numbers" field and a "message" field. Each field is essentially a variable and the field name is the variable name. The main difference is that the variable is accessed from the structure via dot notation instead of directly from the Matlab workspace. For example, if I want to get the "numbers" field, I would do
```matlab
myStructure.numbers
```

In an OOP style, variables are organized in an "object". An object is very similar to a structure; it also has saved variables (known as properties) that can be accessed via dot indexing. A key difference from structures is that an object can also include functions for those variables (known as methods). These methods are also accessed via dot indexing.

For example, let's say we want to take the average of the numbers stored in "myStructure". Then we would give the "numbers" field as an input to the "mean" function:
```matlab
myAverage = mean( myStructure.numbers );
```

Now suppose I have an object named "myObject" that has a "numbers" property and an "average" method. Then I could do
```matlab
myAverage = myObject.average;
```
to take an average of the numbers saved in myObject. I didn't need to provide the numbers as an input because the "average" method is saved together with the "numbers" property in myObject.

It's important to note that methods can still take additional input arguments. For example, I might do
```matlab
myAverage = myObject.average('includenan')
```
to specify how to treat NaN values when taking an average of numbers stored in myObject. However, the number of inputs is often smaller than the number of inputs required for a function because the method is already associated with some inputs via the object's properties.


### Practical Implications

Okay, that's neat but why should I care?

The main implication for DASH users is that most methods / functions are accessed via dot notation. For example
```matlab
kalmanFilter.run
```
might be used to run a kalman filter, or
```matlab
stateVector.build
```
might be used to build a state vector ensemble.


### More help

If you still aren't sure how this works, check out the tutorials, which provide step-by-step instructions for working with DASH.

If you are interested in learning more about OOP in Matlab, check out the [documentation for object-oriented design](https://www.mathworks.com/help/matlab/object-oriented-design-with-matlab.html).

[All tutorials](welcome)
