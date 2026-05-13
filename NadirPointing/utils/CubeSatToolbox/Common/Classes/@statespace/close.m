function g = close( h, e )

%--------------------------------------------------------------------------
%   Close the loop on a statespace control system.
%   e relates y to u.
%   u = -ey
%--------------------------------------------------------------------------
%   Form:
%   g = close( h, e )
%--------------------------------------------------------------------------
%
%   ------
%   Inputs
%   ------
%   h           (:)   Object of class statespace
%   e           (:)   Connection matrix
%
%   -------
%   Outputs
%   -------
%   g           (:)   Closed loop system
%
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
%   Copyright (c) 2000 Princeton Satellite Systems, Inc.
%   All rights reserved.
%--------------------------------------------------------------------------

g   = h;

if( isempty(e) )
  g.a = g.a - g.b*g.c;
else	
  g.a = g.a - g.b*e*g.c;
end

% PSS internal file version information
%--------------------------------------
% $Date: 2012-07-28 23:52:41 -0400 (Sat, 28 Jul 2012) $
% $Revision: 30112 $
