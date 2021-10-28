%% dash.dataSource  Classes that read data from different types of sources files
% ----------
%   The Base class implements an interface for loading data from source
%   files. Subclasses actually implement the steps needed to extract data
%   from different types of files.
%
%   These classes are used by gridfile objects to load data from different
%   files within a common framework.
% ----------
% Abstract Superclasses:
%   Base - Objects that read data from a source file
%   hdf  - Objects that read data from HDF5 formatted files (NetCDF, .mat)
%
% Concrete Subclasses:
%   mat  - Objects that read data from MAT-files
%   nc   - Objects that read data from NetCDF files
%   text - Objects that read data from delimited text files
%
% Tests:
%   tests - Unit tests for classes in the package
%
% <a href="matlab:dash.doc('dash.dataSource')">Documentation Page</a>