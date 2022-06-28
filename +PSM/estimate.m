function[Ye] = estimate(obj, F, X)
%% PSM.estimate  Compute observation estimates by applying forward models to a state vector ensemble
% ----------
%   Ye = PSM.estimate(F, X)
%   Ye = PSM.estimate(F, ens)
%   Computes observation estimates for a set of PSMs / forward models. For
%   each PSM, uses the PSM's rows to extract forward model inputs from the
%   state vector ensemble. These inputs are used to run the PSM, and the
%   PSM outputs are added to the output array of observation estimates.
%
%   Forward models should be provided either as a cell vector, where each
%   element holds a scalar PSM object. If all the PSM objects are the same
%   type of PSM, you may alternatively provide the PSM objects directly as
%   PSM vector. Each PSM object is used to produce estimates for a
%   particular observation site. Each row of the output array Ye holds the
%   estimates for a particular PSM / observation site. The order of rows of
%   Ye will match the order of input PSMs.
%
%   You can provide the state vector ensemble either directly as a numeric
%   array, or as an ensemble object. If using a numeric array, the rows are
%   treated as state vector elements and the columns are ensemble members.
%   Any elements along the third dimension are treated as individual
%   ensembles in an evolving set. If using an ensemble object, the object
%   may implement either a static or an evolving ensemble. The number of
%   columns of Ye will match the number of ensemble members, and the number
%   of elements along the third dimension of Ye will match the number of
%   evolving ensembles.
%
%   The method uses PSM rows to extract forward model inputs from the state
%   vector ensemble. Thus, you must call the "rows" command on each input
%   PSM object before using PSM.estimate. If any of the PSM objects defines
%   different rows for different ensemble members, then all of the PSM
%   objects must either 1. Define rows for the same number of ensemble
%   members, or 2. Use the same rows for all ensemble members. Likewise, if
%   any of the PSM objects defines different rows for different ensembles
%   in an evolving set, then all of the PSM objects must either 1. Define
%   rows for the same number of evolving ensembles, or 2. Use the same rows
%   for all evolving ensembles.
%
%   If a PSM fails and Ye is the only output, the method issues a warning
%   that the PSM failed in the console. The Ye values for the PSM will all
%   be NaN.
%
%   [Ye, failed, cause] = PSM.estimate(...)
%   Also returns information about whether each PSM ran successfully or
%   not. The second output notes whether each PSM failed (true) or
%   ran successfully (false). The third output has one element per PSM and
%   reports the causes of any failures. If a PSM ran successfully, the
%   cause for the PSM will be empty. If a PSM failed, the cause for the PSM
%   will contain the error that caused the PSM to fail.
%
%   If a PSM fails and there is more than one output, the method skips over
%   any failed PSMs, but does not issue a warning in the console. The Ye
%   values for the failed PSM will still all be NaN.
%
%   ... = PSM.estimate(..., 'fail', failureResponse)
%   ... = PSM.estimate(..., 'fail', 0|'e'|'error')
%   ... = PSM.estimate(..., 'fail', 1|'s'|'skip')
%   ... = PSM.estimate(..., 'fail', 2|'w'|'warn')
%   Indicate how the method should respond when a PSM fails to run.
%   If 0|'e'|'error', the method throws an error when a PSM fails.
%   If 1|'s'|'skip', the method skips over the PSM, but does not issue a
%   warning to the console. If 2|'w'|'warn', the method skips over the PSM
%   and also issues a warning to the console.
% ----------
%   Inputs:
%       F (cell vector | PSM vector [nSite]): The forward models for the
%           observation sites. Either a cell vector or a PSM vector with
%           one element per observation site. If a cell vector, each
%           element must hold a scalar PSM object. The PSM objects must all
%           have previously used the "rows" command to define the state
%           vector rows that hold the forward model inputs. 
% 
%           If any PSM objects define different rows for different ensemble
%           members, then all PSM objects must either 1. Define rows for
%           the same number of ensemnble members, or 2. Use the same rows
%           for all ensemble members. If any PSM object define different
%           rows for different ensembles in an evolving set, then all PSM
%           objects must either 1. Define rows for the same number of
%           evolving ensembles, or 2. Use the same rows for all evolving
%           ensembles.
%       X (numeric 3D array [nState x nMembers x nEvolving]): The state
%           vector ensemble provided directly as a numeric array. Each row
%           is a state vector element, each column is an ensemble member,
%           and each element along the third dimension is an ensemble in an
%           evolving set.
%       ens (scalar ensemble object): The state vector ensemble provided as
%           an ensemble object. May implement either a static or an
%           evolving ensemble.
%       failureResponse (string scalar | scalar logical): Indicates how the
%           method should respond when a PSM fails to run.
%           [0|'e'|'error']: Throw an error
%           [1|'s'|'skip']: Skip the PSM, but do not issue a warning in the console
%           [2|'w'|'warn']: Issue a warning in the console and skip the PSM
%
%   Outputs:
%       Ye (numeric 3D array [nSite x nMembers x nEvolving]): The
%           observation estimates generated by applying the forward models
%           to the state vector ensemble.
%       failed (logical vector [nSite]): Indicates if each of the PSMs
%           failed to run (true), or ran successfully (false)
%       cause (cell vector [nSite], {scalar MException | []}): Indicates
%           the causes of any failed PSMs. A cell vector with one element
%           per PSM. If a PSM ran successfully, the associated element is
%           empty. If a PSM failed, the associated element holds the error
%           that caused the failure.
%
% <a href="matlab:dash.doc('PSM.estimate')">Documentation Page</a>

