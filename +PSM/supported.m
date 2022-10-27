function[names] = supported
%% PSM.supported  Return the list of PSMs supported by the DASH toolbox
% ----------
%   names = PSM.supported
%   Returns the names of proxy forward models supported by the DASH
%   toolbox.
% ----------
%   Outputs:
%       names (string vector): The names of supported forward models
%
% <a href="matlab:dash.doc('PSM.supported')">Documentation Page</a>

names = [...
    "bayfox"
    "baymag"
    "bayspar"
    "bayspline"
    "identity"
    "linear"
    "pdsi"
    "prysm"
    "prysm.cellulose"
%    "prysm.coral"
%    "prysm.icecore"
%    "prysm.speleothem"
    "vslite"
    ];

end