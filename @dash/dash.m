classdef dash
    %% Contains various utility functions
    
    
    methods (Static)
        
        % Misc
        names = dimensionNames;
        assertScalarLogical(input, name);
        varargout = parseInputs(inArgs, flags, defaults, nPrev);
        convertToV7_3(filename);
        
        % File paths
        path = checkFileExists(file);  
        path = unixStylePath(path);
        path = relativePath(toFile, fromFolder);
        
        % Strings and string lists
        tf = isstrflag( input );        
        tf = isstrlist( input );
        assertStrFlag(input, name);
        assertStrList(input, name);
        k = checkStrsInList(input, list, name, message);
        str = errorStringList(strings);

        % Indices
        indices = checkIndices(indices, name, dimLength, dimName);
        assertVectorTypeN(input, type, N, name);
        assertPositiveIntegers(input, allowNaN, allowInf, name);
        indices = equallySpacedIndices(indices);
    end
    
end
        