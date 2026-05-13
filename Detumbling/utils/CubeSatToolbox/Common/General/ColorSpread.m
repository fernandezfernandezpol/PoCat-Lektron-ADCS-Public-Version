function colors = ColorSpread( n )

%--------------------------------------------------------------------------
%   Produce a set of 3-element RGB colors that spread across the colormap.
%
%   Since version 8.
%--------------------------------------------------------------------------
%   Form:
%   colors = ColorSpread( n )
%--------------------------------------------------------------------------
%
%   ------
%   Inputs
%   ------
%   n             (1,1)    Number of colors to produce
%
%   -------
%   Outputs
%   -------
%   colors        (n,3)    n rows of colors
%
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
%   Copyright (c) 2009 Princeton Satellite Systems, Inc. 
%   All rights reserved.
%--------------------------------------------------------------------------

cM = get(0,'defaultfigurecolormap');
nCM = size(cM,1);
colors = zeros(n,3);
for i=1:n
   row = floor(rem(i*(nCM-1)/n,nCM))+1;
   colors(i,:) = cM(row,:);
end


% PSS internal file version information
%--------------------------------------
% $Date: 2015-03-13 12:29:00 -0400 (Fri, 13 Mar 2015) $
% $Revision: 39887 $
