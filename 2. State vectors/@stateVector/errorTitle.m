function[str] = errorTitle(obj)
% Returns a string identifying the stateVector object for use in error
% messages.
%
% str = obj.errorTitle
% Returns the string for the error message.
%
% ----- Outputs -----
%
% str: An identifying string for error messages.

if obj.name == ""
    str = 'this stateVector';
else
    str = sprintf('the stateVector "%s"', obj.title);
end

end