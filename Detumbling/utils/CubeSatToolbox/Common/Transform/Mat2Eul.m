function e = Mat2Eul( m, e )	
	
%--------------------------------------------------------------------------
%   Converts an orthonormal transformation matrix into 3-2-1 Euler angles.
%   Uses the input e(1) for e(1) near the singularity.
%
%--------------------------------------------------------------------------
%   Form:
%   e = Mat2Eul( m, e )	
%--------------------------------------------------------------------------
%
%   ------
%   Inputs
%   ------
%   m		(3,3)  Orthonormal transformation matrix
%   e		(3,1)  Euler angles
%
%   -------
%   Outputs
%   -------
%   e		(3,1)  Euler angles
%
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
%   Copyright (c) 1994 Princeton Satellite Systems, Inc. 
%   All rights reserved.
%--------------------------------------------------------------------------
%   Since version 1.
%--------------------------------------------------------------------------

% Check to see if the transformation matrix is nearly singular

if nargin == 1,
  e = zeros(3,1);
end

if abs(1-abs(m(1,3))) < 10*eps,
 
  if abs(m(1,3)) > 1,
    e(2) = asin(-sign(m(1,3)));
  else
  e(2) = atan2(-m(1,3),0.5*(norm([m(1,1) m(1,2)]) + norm([m(2,3) m(3,3)])));
  end
  e(3) = e(1) - atan2(m(2,1),m(2,2));

else

  e(1) = atan2(m(2,3),m(3,3));
  e(2) = atan2(-m(1,3),0.5*(norm([m(1,1) m(1,2)]) + norm([m(2,3) m(3,3)])));
  e(3) = atan2(m(1,2),m(1,1));

end

%--------------------------------------
% PSS internal file version information
%--------------------------------------
% $Date: 2016-03-18 15:46:49 -0400 (Fri, 18 Mar 2016) $
% $Revision: 41954 $
