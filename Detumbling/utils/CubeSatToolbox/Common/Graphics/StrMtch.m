function k = StrMtch( s, sM )

%--------------------------------------------------------------------------
%   In a matrix with each row a string finds the matching string
%
%   Since version 1.
%--------------------------------------------------------------------------
%   Form:
%   k = StrMtch( s, sM )
%--------------------------------------------------------------------------
%
%   ------
%   Inputs
%   ------
%   s                   String
%   sM                  Strings to test
%
%   -------
%   Outputs
%   -------
%   k                   Row index for matching string
%
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
%	 Copyright 1995 Princeton Satellite Systems, Inc. All rights reserved.
%--------------------------------------------------------------------------

[r,c] = size(sM);

for k = 1:r
  if( strcmp(s,sM(k,1:length(s))) == 1 ) 
	return
  end
end

k = 0;

% PSS internal file version information
%--------------------------------------
% $Date: 2013-07-29 10:21:12 -0400 (Mon, 29 Jul 2013) $
% $Revision: 34948 $
