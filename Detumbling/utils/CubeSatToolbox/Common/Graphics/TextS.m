function TextS( x, y, s, k )

%--------------------------------------------------------------------------
%   Prints labels on a graph.
%
%   Since version 1.
%--------------------------------------------------------------------------
%   Form:
%   TextS( x, y, s, k)
%--------------------------------------------------------------------------
%
%   ------
%   Inputs
%   ------
%   x                 x location
%   y                 y location
%   s          (:)    Text
%   k                 Passed to text
%
%   -------
%   Outputs
%   -------
%   None
%
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
%	Copyright (c) 1996 Princeton Satellite Systems, Inc. 
%   All rights reserved.
%--------------------------------------------------------------------------


[style,font,fSI] = PltStyle;

if( nargin < 4 )
  text(x,y,s,'FontWeight',style,'FontName',font,'FontSize',12+fSI);
else
  text(x,y,s,k,'FontWeight',style,'FontName',font,'FontSize',12+fSI);
end

% PSS internal file version information
%--------------------------------------
% $Date: 2013-07-29 10:10:35 -0400 (Mon, 29 Jul 2013) $
% $Revision: 34930 $
