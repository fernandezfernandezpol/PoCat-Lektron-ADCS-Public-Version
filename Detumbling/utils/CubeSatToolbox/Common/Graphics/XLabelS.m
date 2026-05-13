function XLabelS( x, font )

%--------------------------------------------------------------------------
%   Creates an xlabel using the toolbox style settings
%   x can be entered as 'text@fontName' to get a different font.
%
%   Since version 1.
%--------------------------------------------------------------------------
%   Form:
%   XLabelS( x, font )
%--------------------------------------------------------------------------
%
%   ------
%   Inputs
%   ------
%   x          (:)    Text
%   font       (1,:)  Font name
%
%   -------
%   Outputs
%   -------
%   None
%
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
%   Copyright (c) 1995-2000 Princeton Satellite Systems, Inc.
%   All rights reserved.
%--------------------------------------------------------------------------

[style,fontX,fSI] = PltStyle;

if( nargin < 2 )
  font = fontX;
end

j = strfind(x,'@');
if( ~isempty(j) )
  font = DeBlankLT(x((j+1):end));
  x    = x(1:(j-1));
end

xlabel(x,'FontWeight',style,'FontName',font,'fontsize',11+fSI);


%--------------------------------------
% PSS internal file version information
%--------------------------------------
% $Date: 2014-07-03 12:22:23 -0400 (Thu, 03 Jul 2014) $
% $Revision: 38045 $
