---
sections:
  - Metadata conflicts
  - Specify metadata
  - Convert metadata
  - Reset metadata options
---
# Metadata conflicts

When state vector builds an ensemble, it requires [coupled variables](couple) to have the same metadata in each ensemble member. However, this can cause a conflict when coupled variables use metadata in different formats. For example, say I have two coupled variables: "X_annual" is annually resolved and its time metadata is a numeric vector of years; "X_monthly" has monthly resolution and its time metadata is a datetime vector, so something like:
```matlab
time_annual = 1850:2005;
time_monthly = datetime(1850,1,15):calmonths(1):datetime(2005,1,15);
```
If time is an ensemble dimension, we will be unable to couple the two variables because time metadata for "X_annual" is numeric, while metadata for time metadata for "X_monthly" is datetime. In order to couple these variables, we will need to adjust the time metadata for one of the variables. There are two methods to adjust metadata: you can either specify metadata for reference indices directly, or you can provide a function to convert the metadata for a variable.

<br>
### Specify metadata

You can use the "specifyMetadata" command to provide metadata directly at the reference indices of a variable. To do so, provide in order
1. The name of the variable
2. The dimension for which you are specifying metadata, and
3. The metadata at the reference indices.

 Building on the previous example, let's say that the reference indices for "X_annual" point to each year, and that the reference indices for "X_monthly" point to the first month of each year
 ```matlab
 indices_annual = 1:156;
 indices_monthly = 1:12:1872;
 ```


 In this case, we are selecting ensemble members from different years. One option is to specify annual metadata for the "X_monthly" reference indices, such as:
 ```matlab
 newMeta = 1850:2005;
 sv = sv.specifyMetadata("X_monthly", "time", newMeta);
 ```

 Alternatively, we could use January of each year for the annual data.
 ```matlab
 newMeta = datetime(1850,1,15):calyears(1):datetime(2005,1,15);
 sv = sv.specifyMetadata("X_annual", "time", newMeta)
 ```

 Note that when you specify metadata, it is applied to the reference indices and each row must be unique.

<br>
### Convert metadata

 Alternatively, you can provide a function to convert a dimension's metadata using the "convertMetadata" command. To do so, provide in order
 1. The name of the variable
 2. The dimension for which to convert metadata, and
 3. A function handle for the function used to convert metadata.

 Using our previous example, we could consider converting the datetime metadata for "X_monthly" to a numeric vector using the built-in "year" function.
 ```matlab
 convertFunction = @year;
 sv = sv.convertMetadata("X_monthly", "time", convertFunction);
 ```

 One benefit to using a conversion function is that you do not need to know the metadata at the different reference indices.

Metadata is converted via:
```matlab
newMetadata = convertFunction( oldMetadata );
```
 If the conversion function requires additional arguments, such as
 ```matlab
 newMetadata = convertFunction(oldMetadata, arg2, arg3, arg4)
 ```
 place the additional arguments in order in a cell vector and provide them as the fourth input to "convertMetadata", as per
 ```matlab
 extraArgs = {arg1, arg2, arg3, arg4, ..., argN};
 sv = sv.convertMetadata(variable, dimension, convertFunction, extraArgs);
 ``

 For example, we could use the built-in "datetime" function to convert the metadata for "X_annual" to January of each year. To do so, the conversion would look like:
 ```matlab
 monthlyMeta = datetime( yearsMeta, 1, 15)
 ```
 so we would do
 ```matlab
 convertFunction = @datetime;
 extraArgs = {1, 15};
 sv = sv.convertMetadata("X_annual","time", convertFunction, extraArgs);
 ```

<br>
### Reset metadata options

 If necessary, you can delete specified metadata and conversion functions using the "resetMetadata" method.
 Use
 ```matlab
 sv = sv.resetMetadata
 ```
 to reset metadata for all dimensions.

 To reset metadata for specific variables use:
 ```matlab
 sv = sv.resetMetadata(variableNames)
 ```
 where variableNames is a string vector.

 And to reset metadata for specific dimensions of certain variables, use:
 ```matlab
 sv = sv.resetMetadata(variableNames, dimensionNames)
 ```
where dimensionNames is a string vector.
