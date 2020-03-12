function[nanflag] = getNaNflag( obj, v, d, nanflag, inArgs )
% Implements nanflag behavior for complex edits.

% Quick reference
takeMean = obj.var(v).takeMean(d);

% If setting takeMean to false -- if the user provided a
% nanflag, throw error. For anything else, set the nanflag to [].
if ~takeMean
    if ismember('nanflag', inArgs) && ~isempty(nanflag)
        error('Cannot specify a NaN flag when not taking a mean.');
    elseif ~isempty(nanflag)
        fprintf('No longer taking a mean. Deleting NaN flag for dimension %s of variable %s.\n', obj.var(v).dimID(d), obj.varName(v) );
    end        
    nanflag = [];

% If setting takeMean to true -- if nanflag is [], default to includenan,
% otherwise error check
else
    if isempty(nanflag)
        nanflag = "includenan";
    elseif ~isstrflag(nanflag) || ~ismember(nanflag, ["omitnan","includenan"])
        error('nanflag must be either "omitnan" or "includenan".');
    end
end

end