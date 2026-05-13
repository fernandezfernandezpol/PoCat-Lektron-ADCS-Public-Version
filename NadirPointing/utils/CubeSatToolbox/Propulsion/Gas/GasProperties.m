function [m, gamma] = GasProperties( gas )

%--------------------------------------------------------------------------
%   Returns gas properties.
%
%   Since version 8.
%--------------------------------------------------------------------------
%   Form:
%   [m, gamma] = GasProperties( gas )
%--------------------------------------------------------------------------
%
%   ------
%   Inputs
%   ------
%   gas           (1,:)  Name of gas to be used.
%
%   -------
%   Outputs
%   -------
%   m             (1,1)  Molecular weight
%   gamma         (1,1)  Ratio of specific heats
%
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
%   Copyright (c) 2009 Princeton Satellite Systems, Inc.
%   All rights reserved.
%--------------------------------------------------------------------------

% Demo
%-----
if( nargin < 1 )
    gas  = {'hydrogen';...
            'helium';...
            'nitrogen';...
            'air';...
            'argon';...
            'krypton'};
    disp('     Gas         Mol Wt       Gamma')
    for k = 1:length(gas)
        [m, gamma] = GasProperties( gas{k} );
        disp(sprintf('%10s %12.4f %11.3f',gas{k},m,gamma))
    end
    clear m;
    return;
end

fuels = ['hydrogen';...
         'helium  ';...
		 'nitrogen';...
		 'air     ';...
		 'argon   ';...
		 'krypton '];

m   = [2.0  4.0   28.0 28.9 39.9   83.8]*1.e-3;
g   = [1.4  1.667  1.4  1.4  1.667  1.667];

k   = StrMtch( lower(gas), fuels );
if( k == 0 )
  error([gas ' is not in the database']);
end

gamma = g(k);
m     = m(k);

%--------------------------------------
% PSS internal file version information
%--------------------------------------
% $Date: 2015-03-12 14:59:40 -0400 (Thu, 12 Mar 2015) $
% $Revision: 39875 $
