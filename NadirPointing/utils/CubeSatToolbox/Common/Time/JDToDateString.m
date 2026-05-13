function s = JDToDateString( jD )

%--------------------------------------------------------------------------
%   Convert Julian Date to the form '04/20/2000 00:00:00'
%  
%   Typing JDToDateString returns the current date.
%--------------------------------------------------------------------------
%   Form:
%    s = JDToDateString( jD )
%--------------------------------------------------------------------------
%
%   ------
%   Inputs
%   ------
%   jD            (1,1)   Julian Date   
%
%   -------
%   Outputs
%   -------
%   s             (1,:)   String 'mm/dd/yyyy hh:mm:ss'
%
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
%   Copyright (c) 2000-2004 Princeton Satellite Systems, Inc.
%   All rights reserved.
%--------------------------------------------------------------------------

if( nargin < 1 )
  jD = Date2JD;
end

d = JD2Date( jD );
s = sprintf( '%2.2i/%2.2i/%4i %2.2i:%2.2i:%05.2f', d(2), d(3), d(1), d(4:6) );

% PSS internal file version information
%--------------------------------------
% $Date: 2012-07-31 18:49:39 -0400 (Tue, 31 Jul 2012) $
% $Revision: 30228 $
