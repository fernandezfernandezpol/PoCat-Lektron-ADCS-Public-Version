function [style, font, fSI] = PltStyle()

%--------------------------------------------------------------------------
%   Edit this to globally change the plot styles for the plot labels
%
%   Since version 1.
%--------------------------------------------------------------------------
%   Form:
%   [style, font, fSI] = PltStyle()
%--------------------------------------------------------------------------
%
%   ------
%   Inputs
%   ------
%   none
%
%   -------
%   Outputs
%   -------
%   style     Font style
%   font      Font
%   fSI       Font size increase (above default size)
%
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
%   Copyright (c) 1995 Princeton Satellite Systems, Inc. 
%   All rights reserved.
%--------------------------------------------------------------------------

global fontSizeIncrease

style = 'bold';
font  = 'Helvetica';
fSI = fontSizeIncrease;
if( isempty(fSI) )
   fSI = 0;
end

% PSS internal file version information
%--------------------------------------
% $Date: 2013-07-29 10:13:48 -0400 (Mon, 29 Jul 2013) $
% $Revision: 34936 $
