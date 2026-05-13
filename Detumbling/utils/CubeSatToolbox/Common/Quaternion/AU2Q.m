function q = AU2Q( angle, u )

%--------------------------------------------------------------------------
%   Convert an angle and a unit vector to a quaternion.
%   Transforms from the unrotated to the rotated frame.
%
%--------------------------------------------------------------------------
%   Form:
%   q = AU2Q( angle, u )
%--------------------------------------------------------------------------
%
%   ------
%   Inputs
%   ------
%   angle         (1,:)   Angle (rad)
%   u             (3,1)   Unit vector
%
%   -------
%   Outputs
%   -------
%   q             (4,:)   Quaternion from unrotated to rotated frame
%
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
%		Copyright (c) 1997, 2012 Princeton Satellite Systems, Inc.
%   All rights reserved.
%--------------------------------------------------------------------------
%   Since version 2.
%--------------------------------------------------------------------------
% Assume it is a valid unit vector
%---------------------------------
halfAngle = angle/2;
c         = cos( halfAngle );
s         = sin( halfAngle );

q         = [ c; -[s*u(1);s*u(2);s*u(3)] ];

%--------------------------------------
% PSS internal file version information
%--------------------------------------
% $Date: 2016-03-18 15:02:51 -0400 (Fri, 18 Mar 2016) $
% $Revision: 41948 $
