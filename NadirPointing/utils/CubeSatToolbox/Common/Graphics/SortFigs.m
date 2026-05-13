function SortFigs( h, xo )

%--------------------------------------------------------------------------
%   Sort figure windows by cascading them.
%--------------------------------------------------------------------------
%   Form:
%   SortFigs( h, xo )
%--------------------------------------------------------------------------
%
%   ------
%   Inputs
%   ------
%   h            (1,:)   Array of figure handles. Optional. If not
%                        provided, all current figure handles will be used.
%   xo            (1)    Horizontal offset for first figure. Optional,
%                        default is 0.
%
%   -------
%   Outputs
%   -------
%   h            (1,:)   Array of figure handles.
%
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
%   Copyright (c) 2005 Princeton Satellite Systems, Inc.
%   All rights reserved.
%--------------------------------------------------------------------------

if( nargin<2 )
   xo = 0;
end

if( ~nargin || isempty(h) )
   h = findobj('type','figure');
end
if( isempty(h) )
   return;
end

h = h(ishandle(h));
pos = get(h,'position');
if( ~iscell(pos) )
   pos = {pos};
end

ps = get(0,'screensize');

for i=1:length(h)
   set(h(i),'position',[xo+(i-1)*15,ps(4)-pos{i}(3)-15*(i-1),pos{i}(3:4)]);
   figure(h(i));
end

%--------------------------------------
% PSS internal file version information
%--------------------------------------
% $Date: 2015-03-13 12:29:00 -0400 (Fri, 13 Mar 2015) $
% $Revision: 39887 $
