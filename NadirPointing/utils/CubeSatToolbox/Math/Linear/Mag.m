function m = Mag( u )

%--------------------------------------------------------------------------
%   Given a 3-by-n matrix where each column represents a vector, return a
%   row vector of the magnitudes of each column.
%
%   Since version 1.
%--------------------------------------------------------------------------
%   Form:
%   m = Mag( u )
%--------------------------------------------------------------------------
%
%   ------
%   Inputs
%   ------
%   u            (:,:)  Vectors
%
%   -------
%   Outputs
%   -------
%   m            (:)   Corresponding magnitudes
%
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
%   Copyright (c) 1995 Princeton Satellite Systems, Inc. 
%   All rights reserved.
%--------------------------------------------------------------------------

m = sqrt(sum(u.^2));


%--------------------------------------
% PSS internal file version information
%--------------------------------------
% $Date: 2015-03-05 11:37:48 -0500 (Thu, 05 Mar 2015) $
% $Revision: 39770 $
