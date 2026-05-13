function [s, c] = SCHarm( a, n )

%--------------------------------------------------------------------------
%   Generate a series of sine and cosine harmonics of the arguments
%
%   Since version 1.
%--------------------------------------------------------------------------
%   Form:
%   [s, c] = SCHarm( a, n )
%--------------------------------------------------------------------------
%
%   ------
%   Inputs
%   ------
%   a                  column vector (m,1) argument (rad)
%   n                  number of harmonics
%
%   -------
%   Outputs
%   -------
%   s                  vector of sine harmonics
%   c                  vector of cosine harmonics
%
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
%	Copyright (c) 1993 Princeton Satellite Systems, Inc. 
%   All rights reserved.
%--------------------------------------------------------------------------

s = zeros(length(a),n);
c = zeros(length(a),n);

if( n > 0 )

  [nr,nc] = size(a);
  if ( nr == 1 )
    s(:,1) = sin(a');
    c(:,1) = cos(a');
  else
    s(:,1) = sin(a);
    c(:,1) = cos(a);
  end

  for i = 2:n
    s(:,i) = s(:,i-1).*c(:,1) + c(:,i-1).*s(:,1);
    c(:,i) = c(:,i-1).*c(:,1) - s(:,i-1).*s(:,1);
  end
end


% PSS internal file version informaion
%--------------------------------------
% $Date: 2013-07-29 09:22:36 -0400 (Mon, 29 Jul 2013) $
% $Revision: 34865 $
