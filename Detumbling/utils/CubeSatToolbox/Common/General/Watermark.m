function Watermark( string, fig, pos, color  )

%% Add a watermark to a figure. 
% This function creates two axes, one for the image and one for the text. 
% Calling it BEFORE plotting can cause unexpected results. It will reset 
% the current axes after adding the watermark. The default position is
% the lower left corner, (2,2).
%
% Leaving out the color input will cause the logo to use the color of the
% figure for the background. You can set a default color to a persistent
% variable using the second form; clear the function to reset it.
%--------------------------------------------------------------------------
%   Form:
%   Watermark( string, fig, pos, color  )
%   Watermark( color ), set a temporary background color
%--------------------------------------------------------------------------
%
%   ------
%   Inputs
%   ------
%   string     (1,:) Name, i.e. product name
%   fig        (1,1) Figure hangle
%   pos        (1,2) Coordinates, (left, bottom)
%   color      (3,1) Background color, [R G B]
%
%   -------
%   Outputs
%   -------
%   none
%
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
%	 Copyright (c) 2013 Princeton Satellite Systems, Inc.
%    All rights reserved.
%--------------------------------------------------------------------------

persistent setColor

if (nargin==1 && isnumeric(string) && length(string)==3)
  setColor = string;
  return;
end

if nargin < 1 || isempty(string)
  string = 'Spacecraft Control Toolbox';
end
  
if (nargin<2 || isempty(fig))
  fig = NewFig('Watermark Demo');
end

if (nargin<3 || isempty(pos))
  pos = [2 2];
end

if( nargin<4 || isempty(color))
  if isempty(setColor)
    color = get(fig,'color');
  else
    color = setColor;
  end
end

aX = [];
if ~isempty(get(fig,'CurrentAxes'))
  aX = gca;
end

% Draw the logo
%--------------
d = load('SwooshWatermark');
posSwoosh = [pos(1:2) 50 25];
axes( 'Parent', fig, 'box', 'off', 'units', 'pixels', 'position', posSwoosh );
xI = find(squeeze(d.x(:,:,1)==255));
hC = color;
xx = squeeze(d.x(:,:,1));
xx(xI) = floor(hC(1)*255);
xy = squeeze(d.x(:,:,2));
xy(xI) = floor(hC(2)*255);
xz = squeeze(d.x(:,:,3));
xz(xI) = floor(hC(3)*255);
d.x(:,:,1) = xx;
d.x(:,:,2) = xy;
d.x(:,:,3) = xz;
image( d.x );
axis off
posText = [pos(1)+18 pos(2)+5 200 15];
axes( 'Parent', fig, 'box', 'off', 'units', 'pixels', 'position', posText );
t = text(0,0.5,string);
if (all(hC)==0)
  set(t,'color',[1 1 1]);
end
axis off

if ~isempty(aX)
  set(fig,'CurrentAxes',aX);
end
  

%--------------------------------------
% PSS internal file version information
%--------------------------------------
% $Date: 2016-03-24 16:18:36 -0400 (Thu, 24 Mar 2016) $
% $Revision: 42057 $
