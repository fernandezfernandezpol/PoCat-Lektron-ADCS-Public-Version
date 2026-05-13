function h = UnnormalizeGravity( g )

%% Remove normalization from a gravity model
%
% Removes normalization from a gravity model.
%
% Type UnnormalizeGravity for a demo.
%--------------------------------------------------------------------------
%   Form:
%   h = UnnormalizeGravity( g )
%--------------------------------------------------------------------------
%
%   ------
%   Inputs
%   ------
%   g   (.) Gravity model data structure
%
%   -------
%   Outputs
%   -------
%   h   (.) Gravity model data structure
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
%   Copyright (c) 2016 Princeton Satellite Systems, Inc. 
%   All rights reserved.
%--------------------------------------------------------------------------
%   Since 2016.1
%--------------------------------------------------------------------------


if( nargin < 1 )
           %m  1        2        3        4
  gEM10.c = [ 0.00104  2.43404  0.0      0.0           % 2
              2.02855  0.89272  0.70028  0.0           % 3
             -0.53521  0.35208  0.98850 -0.19531   ];  % 4
            
                      
  gEM10.s = [-0.00243 -1.39907  0.0      0.0           % 2
              0.25197 -0.62346  1.41250  0.0           % 3
             -0.46926  0.66404 -0.20179  0.29883   ];  % 4 
            
  gEM10.c   = [zeros(2,4);gEM10.c]*1e-6;
  gEM10.s   = [zeros(2,4);gEM10.s]*1e-6;
            
  gEM10.j   = [0 0 -484.16544 0.95838 0.54112]*1e-6;
  gEM10.mu  = 398600.47e9;
  gEM10.a   = 6378139.0;
  UnnormalizeGravity( gEM10 )
  return
end

h     = g;
nN    = length(g.j)-1;
f     = NormalizationMatrix( nN, nN);
h.c   = g.c./f(:,2:end);
h.s   = g.s./f(:,2:end);	
h.j   = g.j./f(:,1)';


%--------------------------------------
% PSS internal file version information
%--------------------------------------
% $Date: 2016-03-14 09:58:32 -0400 (Mon, 14 Mar 2016) $
% $Revision: 41807 $

    
