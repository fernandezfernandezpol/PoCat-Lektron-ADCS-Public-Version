function dateTime = DTSToDTA( t )

%--------------------------------------------------------------------------
%   Converts the date time structure to the date time array
%
%   Typing DTSToDTA returns clock time
%
%   Since version 2.
%--------------------------------------------------------------------------
%   Form:
%   dateTime = DTSToDTA( t )
%--------------------------------------------------------------------------
%
%   ------
%   Inputs
%   ------
%   t          (1,1)   Date/time structure
%                       .year
%                       .month                             
%                       .day                             
%                       .hour                             
%                       .minute                             
%                       .second
%   -------
%   Outputs
%   -------
%   dateTime    (1,6)  [year month day hour minute seconds 
%
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
%   Copyright (c) 1998-2004 Princeton Satellite Systems, Inc.
%   All rights reserved.
%--------------------------------------------------------------------------

if( nargin == 0 ) 
  dateTime = clock;
elseif( isstruct(t) )
  dateTime = [t.year t.month t.day t.hour t.minute t.second];
else
  if( length(t) == 1 )
    dateTime = [t 1 1 0 0 0];
  else
    dateTime = t;
  end
end

% PSS internal file version information
%--------------------------------------
% $Date: 2013-07-31 11:19:23 -0400 (Wed, 31 Jul 2013) $
% $Revision: 35187 $
