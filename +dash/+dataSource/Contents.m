% Classes that read data from different source files
%
% The Base class implements an interface for loading data from source files
% and subclasses provide the functionality needed to extract data from
% different files. These classes are used by gridfile objects to load data
% from different files in a common framework.
%
% Abstract Superclasses:
%   Base - Objects that read data from a source file
%    hdf - Objects that read data from HDF5 formatted files (NetCDF, .mat)
%
% Concrete Subclasses:
%    mat - Objects that read data from MAT-files
%     nc - Objects that read data from NetCDF files
%   text - Objects that read data from delimited text files
%
% Tests:
%   tests - Implement unit tests for classes in the dash.dataSource subpackage
%
% <a href="matlab:dash.doc('dash.dataSource')">Online Documentation</a>