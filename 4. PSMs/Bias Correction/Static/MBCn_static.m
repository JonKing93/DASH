function[X] = MBCn_static( Xo, Xm, Xp, Xd, R, type, normO, normM )
%% Performs the MBCn algorithm using static iteration values.

% Check that all X are matrices
if ~ismatrix(Xo) || ~ismatrix(Xm) || ~ismatrix(Xp) || ~ismatrix(Xd)
    error('Xo, Xm, Xp, and Xd must all be matrices.');
end

% All must have the same number of variables
N = size(Xo,2);
if N ~= size(Xm,2) || N ~= size(Xp,2) || N~=size(Xd,2)
    error('Xo, Xm, Xp, and Xd must have the same number of columns.');
end

% Get indices to concatenate all the data
o = 1:size(Xo,1);
m = max(o)+1:max(o)+size(Xm,1);
p = max(m)+1:max(m)+size(Xp,1);
d = max(p)+1:max(p)+size(Xd,1);

% Concatenate everything
X = [Xo;Xm;Xp;Xd];

% For each variable
for k = 1:N
    
    % Do a static QDM to initialize Xd
    X(d,k) = qdm( X(o,k), X(m,k), X(p,k), type, X(d,k) );
    
    % Do a QDM to initialize Xp
    X(p,k) = qdm( X(o,k), X(m,k), X(p,k) );
    
    % Do quantile map to initialize Xm
    X(m,k) = quantMap( X(o,k), X(m,k) );
    
    % Save the initial QDM
    Xq = [X(p,k); X(d,k)];
end

% Standardize the matrices
X(o,:) = ( X(o,:) - normO(1) ) ./ normO(2);
X([m,p,d],:) = ( X([m,p,d],:) - normM(1) ) ./ normM(2);

% For each iteration
for j = 1:size(R,3)
    
    % Rotate the matrices
    X = X * R(:,:,j);
    
    % For each rotated variable
    for k = 1:N
        
        % Do a static absolute qdm on Xd
        X(d,k) = qdm( X(o,k), X(m,k), X(p,k), X(d,k), 'abs' );
        
        % Do a standard absolute qdm on Xp
        X(p,k) = qdm( X(o,k), X(m,k), X(p,k), 'abs' );
        
        % Get the quantile mapping from Xm to Xo
        X(m,k) = quantMap( X(o,k), X(m,k) );
    end
    
    % Do the inverse rotation
    X = X * R';
end

warning('Need to verify the shuffle is correct.');

% For each variable
for k = 1:N
        
    % Sort the projected variables from the original QDM
    Xq(:,k) = sort( Xq(:,k) );
    
    % Order the sorted variables according to the rank order of the
    % transformed set of projected values
    [~,rankOrder] = sort( X([p,d],k) );
    Xq(:,k) = Xq(rankOrder,k);
end

% Extract the static variables and restore the standardization from the
% observations.
X = Xq .* normO(2) + normO(1);

end