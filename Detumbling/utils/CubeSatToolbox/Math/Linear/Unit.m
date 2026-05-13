function u = Unit( v )

%--------------------------------------------------------------------------
%   Unitize vectors by column.
%
%   Since version 1.
%--------------------------------------------------------------------------
%   Form:
%   u = Unit( v )
%--------------------------------------------------------------------------
%
%   ------
%   Inputs
%   ------
%   v            (:,n)     Vectors
%
%   -------
%   Outputs
%   -------
%   u            (:,n)     Unit vectors
%
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
%	Copyright (c) 1994 Princeton Satellite Systems, Inc. 
%   All rights reserved.
%--------------------------------------------------------------------------

[n,p]  = size(v);

if( n == 1 )
  m = v;
else
  m = sqrt(sum(v.^2));
end

% start with NaN
u = NaN(n,length(m));

% check that magnitudes are not zero
k = find( m > 0 );

if( ~isempty(k) )
  if (p==1)
    % Single column
    u = v/m;
  else
    for j = 1:n
      u(j,k) = v(j,k)./m(k);	
    end 
  end
end


%--------------------------------------
% PSS internal file version information
%--------------------------------------
% $Date: 2013-07-29 09:36:58 -0400 (Mon, 29 Jul 2013) $
% $Revision: 34885 $
