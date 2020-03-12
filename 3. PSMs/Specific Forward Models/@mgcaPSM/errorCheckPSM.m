function[] = errorCheckPSM( obj )
    if ~isvector( obj.H ) || length(obj.H)~=24
        error('H is not the right size.');
    end
    if ~ismember(obj.Species,obj.SpeciesNames)
        error('Species not recognized');
    end
end