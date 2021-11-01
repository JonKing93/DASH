classdef gridMetadata
    %% gridMetadata  Implements metadata for gridded datasets
    %
    
    properties
    
        %% Built-in dimensions
        % These dimensions are hard-coded into various functions in DASH.
        % You CAN rename these dimensions, but DO NOT delete them
        % and DO NOT change their order.
        
        lon;    % Longitude / X-Axis
        lat;    % Latitude / Y-Axis
        lev;    % Level / Height / Z-Axis
        site;   % For proxy sites / tripolar grids / spatial data not on Cartesian Axes
        time;   % Time
        run;    % Run / Ensemble member
        var;    % Climate variable
        
        %% ----- Insert new dimensions after this line -----
        % If you would like to add new dimensions to DASH, add them between
        % the two indicated lines
        
        
        
        %  ----- Stop adding dimensions after this line -----
        
        %% Non-dimensional metadata attributes
        attributes;
    end

    % General object methods: Constructor and disp
    methods        
        function[obj] = gridMetadata(varargin)
        end
        disp(obj);
        dispAttributes(obj);
    end
    
    % Static input error checking
    methods (Static)
        meta = assertField(meta, dim, idHeader);
        tf = hasDuplicateRows(meta);
    end
    
end