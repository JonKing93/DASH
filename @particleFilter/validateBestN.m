function[obj] = validateBestN(obj, type, name, header)
%% particleFilter.validateBestN  Ensure that the "Best N" weighting scheme is valid after updating nMembers
% ----------
%   obj = <strong>obj.validateBestN</strong>(type)
%   Checks that the Best N weighting scheme remains valid after altering
%   the number of members. If setting new values, throws an error if the
%   number of members is less than the number of best N particles. If
%   deleting values and no members remain, reverts to a Bayesian weighting
%   scheme and warns the user.
%
%   obj = <strong>obj.validateBestN</strong>(type, N, header)
%   Customize console messages and error ID headers.
% ----------
%   Inputs:
%       type (string scalar): Indicates the type of operation that resulted
%           in a changed nMembers. Use "set" if setting new values, and
%           "delete" if deleting old values.
%       name (string scalar): The name of the data input being altered.
%       header (string scalar): Header for thrown error IDs.
%
%   Outputs:
%       obj (scalar particleFilter object): The particleFilter object with
%           a valid weighting scheme.
%
% <a href="matlab:dash.doc('particleFilter.validateBestN')">Documentation Page</a>

% Defaults
if ~exist('name','var')
    name = 'values';
end
if ~exist('header','var')
    header = "DASH:particleFilter:validateBestN";
end

% Throw error if setting nMembers < N
if strcmpi(type, 'set') && obj.weightArgs{1}>obj.nMembers
    id = sprintf('%s:tooFewMembers', header);
    ME = MException(id, ['You previously specified a weighting scheme for the ',...
        'best %.f particles in %s, but the new %s only have %.f particles.'],...
        obj.weightArgs{1}, obj.name, name, obj.nMembers);
    throwAsCaller(ME);

% If deleting, disable best N and warn user
elseif strcmp(type, 'delete')
    obj = obj.weights('bayes');

    id = sprintf('%s:disabledWeightingScheme', header);
    warning(id, ['Replacing the "Best N" weighting scheme with the Bayesian weighting ',...
        'scheme because %s no longer has any ensemble members.'], obj.name);
end

end