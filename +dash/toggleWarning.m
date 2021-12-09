function[reset] = toggleWarning(state, warnID)
%% dash.toggleWarning

warn = warning('query', warnID);
warning(state, warnID);
reset = onCleanup(  @()warning(warn.state, warnID)  );

end