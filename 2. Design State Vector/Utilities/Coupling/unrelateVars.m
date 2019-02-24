function[design, rv] = unmarkCoupled( design, v, xv, nowarn )
%
% design = unrelateVars( design, v, xv, nowarn )
% Removes a relationship between variables and 1. a template variable, 2.
% all secondary template variables.
%
% ----- Inputs -----
%
% design: A state vector design
%
% v: Index of variables being unrelated
%
% xv: Index of template variable from which variables are being unrelated.
%
% nowarn: Logical scalar for whether to warn about secondary variables.
%
% ----- Outputs -----
%
% design: Updated design
%
% rv: The template variable and its secondary variables.
%
% ----- Written By -----
% Jonathan King, University of Arizona, 2019

% Error check
if ~isscalar(xv)
    error('template must be a single variable.');
elseif ismember(xv, v)
    error('The template cannot be in the list of variables.');
elseif ~islogical(nowarn) || ~isscalar(nowarn)
    error('nowarn must be a logical scalar.');
end

% Get all secondary template variables
sv = find( design.isCoupled(v,:) );

% Get the set of all variables from which to remove the relationship
rv = [xv, sv];

% For each variable having a relationship removed...
nVar = numel(v);
for k = 1:nVar
    
    % Get the remove variables that are not the variable itself
    rvCurr = rv( rv~=v(k) );
    
    % Unmark the relationship
    design.isCoupled([v(k), rvCurr]) = false;
    design.isCoupled([rvCurr, v(k)]) = false;
end

end