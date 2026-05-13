function Axis3D( s )

%--------------------------------------------------------------------------
%   Adjust 3D axes.
%
%   Axis3D is the same as Axis3D('equal')
%
%   Since version 1.
%--------------------------------------------------------------------------
%   Form:
%   Axis3D( s )
%--------------------------------------------------------------------------
%
%   ------
%   Inputs
%   ------
%   s                 String 'equal' is the only option available
%
%   -------
%   Outputs
%   -------
%   None
%
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
%	Copyright (c) 1995 Princeton Satellite Systems, Inc.
%   All rights reserved.
%--------------------------------------------------------------------------

if( nargin == 0 )
  s = 'equal';
end

s = lower(s);

if( strcmp(s,'equal')  )
  x = get(gca,'XLim');
  y = get(gca,'YLim');
  z = get(gca,'ZLim');
  l = [min([x,y,z]) max([x,y,z])];
  set(gca,'XLim',l)
  set(gca,'YLim',l)
  set(gca,'ZLim',l)
else
  e = [s ' not implemented'];
  error(e);
end


%--------------------------------------
% PSS internal file version information
%--------------------------------------
% $Date: 2014-07-03 15:24:25 -0400 (Thu, 03 Jul 2014) $
% $Revision: 38060 $
