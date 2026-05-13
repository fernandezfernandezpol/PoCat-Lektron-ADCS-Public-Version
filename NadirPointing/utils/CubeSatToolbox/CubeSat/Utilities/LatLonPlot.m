function [lat2,lon2,p] = LatLonPlot( lat, lon, tol, varargin )

%--------------------------------------------------------------------------
%   Plot latitude vs. longitude nicely so that the wrapped longitude does 
%   not create lines across the plot.
%
%   Since version 8.
%--------------------------------------------------------------------------
%   Form:
%   [lat2,lon2] = LatLonPlot( lat, lon, tol, varargin )
%--------------------------------------------------------------------------
%
%   ------
%   Inputs
%   ------
%   lat     (1,:)    Latitude vector (rad)
%   lon     (1,:)    Longitude vector (rad)
%   tol     (1,1)    Tolerance used for WrapSegments call.
%                       See WrapSegments
%   varargin (:)     Any additional inputs are treated as additional inputs
%                    to the plot command, as: plot(x,y,varargin)
%   
%   -------
%   Outputs
%   -------
%   lat2    (1,N)    Cell array of N segments of latitude vectors (rad)
%   lon2    (1,N)    Cell array of N segments of longitude vectors (rad)
%
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
%   Copyright (c) 2009 Princeton Satellite Systems, Inc.
%   All rights reserved.
%--------------------------------------------------------------------------


if( nargin < 3 || isempty(tol) )
   tol = pi;
end

[lon2,w] = WrapSegments( lon, tol );
for i=1:length(w)
   lat2{i} = lat(w{i});
   if( nargout==0 || nargout==3 )
     p(i) = plot(lon2{i},lat2{i},varargin{:});
   end
end

%--------------------------------------
% PSS internal file version information
%--------------------------------------
% $Date: 2015-03-12 11:19:43 -0400 (Thu, 12 Mar 2015) $
% $Revision: 39864 $
