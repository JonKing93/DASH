function dn = daynoleap2datenum(day, pivotyr, format)
%DAYNOLEAP2DATENUM Convert from days since, no leap to serial date number
%
% dn = daynoleap2datenum(day, pivotyr)
% dt = daynoleap2datenum(day, pivotyr, format)
%
% A lot of climate model output is saved with a time scale of "days since
% YYYY-01-01 00:00:00", where every year has 365 days.  This function
% converts those dates into a serial date number.  This can be useful if
% you want to compare model output to real-world data.
%
% Input variables:
%
%   day:        number of days since pivot year
%
%   pivotyr:    pivot year, i.e. year that day count begins (on Jan 1)
%
%   format:     output format, either 'dn' for datenumbers or 'dt' for
%               datetime objects (R2014b+ only)
%
% Output variables:
%
%   dn:         array of datenumbers, same size as day
%
%   dt:         datetime array, same size as day

% Copyright 2012-2015 Kelly Kearney

% Parse format

if nargin < 3
    format = 'dn';
end

% Determine which years in range are leap years

nyr = max(day./365);
yrs = pivotyr:(pivotyr + nyr);

isleap = @(x) (mod(x,4)==0 & mod(x,100)~=0) | mod(x,400) == 0;
leapyrs = yrs(isleap(yrs));

% Calculate date numbers

dayofyear = rem(day, 365);
yr = floor(day/365) + pivotyr;

switch format
    case 'dn'
        dn = datenum(pivotyr, 1, 1) + day;
    case 'dt'
        if verLessThan('matlab', '8.4.0')
            warning('Datetime objects not supported pre-R2014b; defaulting to datenumber output');
            dn = datenum(pivotyr, 1, 1) + day;
        else
            dn = datetime(pivotyr, 1, 1) + day;
        end
    otherwise
        error('Unrecognized output format; must be ''dn'' or ''dt''');
end

% Skip Feb 29 in leap years

for ileap = 1:length(leapyrs)
    needsbump = yr > leapyrs(ileap) | (yr == leapyrs(ileap) & dayofyear >= 59);
    dn(needsbump) = dn(needsbump) + 1;
end

end