function TitleS( x, font )

%--------------------------------------------------------------------------
%   Creates a title using the toolbox style settings.
%   x can be entered as 'text@fontName' to get a different font.
%
%   Since version 1.
%--------------------------------------------------------------------------
%   Form:
%   TitleS( x, font )
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
%   Copyright (c) 1996-2000, 2016 Princeton Satellite Systems, Inc.
%   All rights reserved.
%--------------------------------------------------------------------------
%   2016-02-23: switch from findstr to strfind as per MATLAB recommendation
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

title(x,'FontWeight',style,'FontName',font,'fontsize',12+fSI);

%--------------------------------------
% PSS internal file version information
%--------------------------------------
% $Date: 2016-03-14 11:04:01 -0400 (Mon, 14 Mar 2016) $
% $Revision: 41818 $
