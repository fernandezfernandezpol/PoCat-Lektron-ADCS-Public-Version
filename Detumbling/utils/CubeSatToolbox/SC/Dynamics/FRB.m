function xDot = FRB( x, t, inr, invInr, tExt )

%--------------------------------------------------------------------------
%   Rigid body right-hand-side.
%   See also RBModel.
%
%   Since version 1.
%--------------------------------------------------------------------------
%   Form:
%   xDot = FRB( x, t, inr, invInr, tExt )
%--------------------------------------------------------------------------
%
%   ------
%   Inputs
%   ------
%   x            (7,1)     The state vector [q;w]
%   t            (1,1)     Time
%   inr          (3,3)     Inertia
%   invInr       (3,3)     Inverse inertia
%   tExt         (3,1)     External torque
%
%   -------
%   Outputs
%   -------
%   xDot         (7,1)     The derivative of the state vector
%
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
%   Copyright (c) 1994 Princeton Satellite Systems, Inc.
%   All rights reserved.
%--------------------------------------------------------------------------

xDot   = [QIToBDot(x(1:4),x(5:7));...
          RBModel(inr,x(5:7),tExt,invInr)];  


%--------------------------------------
% PSS internal file version information
%--------------------------------------
% $Date: 2013-07-26 14:42:05 -0400 (Fri, 26 Jul 2013) $
% $Revision: 34719 $
