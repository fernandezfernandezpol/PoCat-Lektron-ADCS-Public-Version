function p = Map( planet, mType, noNewFig )

%--------------------------------------------------------------------------
%   Draws a 2 dimensional or three dimensional map of a planet. 
%
%   Turns on mouse driven 3D rotation if mType == '3d'. String inputs are
%   not case sensitive. planet is the name of a .mat file with the
%   variables planetMap and planetColorMap. Your monitor must be set to
%   thousands of colors.
%
%   The planetColorMap is not needed if the planetMap is true color, with
%   channels for R, G, B (mxnx3).
%
%   The radius field may be an array of semimajor axes, (1x3). See Ellipsd.
%
%   Since version 2.
%--------------------------------------------------------------------------
%   Form:
%   p = Map( planet, mType, noNewFig )
%--------------------------------------------------------------------------
%
%   ------
%   Inputs
%   ------
%   planet        (1,:)    Any planet name or the structure
%                            planet.planetMap
%                            planet.planetColorMap
%                            planet.radius
%   mType         (2,:)   '2d' or '3d' default is '3d'
%
%   -------
%   Outputs
%   -------
%   p             (:)      Planet image data structure
%
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
%   Copyright (c) 1997 Princeton Satellite Systems, Inc. 
%   All rights reserved.
%--------------------------------------------------------------------------

% Check input lists
%------------------
if( nargin < 1 )
  planet = 'Earth';
end

if( nargin < 2 )
  mType = '3d';
else
  mType = lower(mType);
end

if( isstruct( planet ) ~= 1 )
  eval(['load ' planet])
end

if( nargout == 0 )
  if( strcmp(mType,'3d') )
    if( nargin < 3 ) 
       NewFig('Globe')
    end
    dPlanet.r = planet.radius;
    if( length( dPlanet.r ) == 1 )
      [x,y,z] = sphere(50);
      x       = x*planet.radius;
      y       = y*planet.radius;
      z       = z*planet.radius;
    else
      [x, y, z] = Ellipsd( dPlanet.r(1), dPlanet.r(2), dPlanet.r(3) );
    end
	  hSurf   = surface(x,y,z);
	  grid on;
    % truecolor or indexed?
    [pmr,pmc,pmd]=size(planet.planetMap);
    if( pmd==3 )
      % truecolor
      pmap = planet.planetMap;
      for i=1:3
         pmap(:,:,i)=flipud(pmap(:,:,i));
      end
      set(hSurf,'Cdata',pmap,'Facecolor','texturemap');
    else
      set(hSurf,'CData',double(flipud(planet.planetMap)),'FaceColor','texturemap')
      colormap( planet.planetColorMap );
    end
    set(hSurf,'edgecolor', 'none',...
          'EdgeLighting', 'gouraud','FaceLighting', 'gouraud',...
          'specularStrength',0.1,'diffuseStrength',0.9,...
          'SpecularExponent',0.5,'ambientStrength',0.2,...
          'BackFaceLighting','unlit');

    view(3);
    XLabelS('x (km)')
    YLabelS('y (km)')
    ZLabelS('z (km)')
    rotate3d on
    axis image
  else % 2d
    if( nargin < 3 ) 
       NewFig('Map')
    end
    [xdim,ydim]=size(planet.planetMap);
    plot(0,0), hold on
    axis([-180 180 -90 90])
    x=linspace(-180,180,xdim);
    y=linspace(90,-90,ydim);
    im = image(x,y,planet.planetMap);
    colormap(planet.planetColorMap)
    axis equal, axis tight
    XLabelS('East Longitude (deg)')
    YLabelS('Latitude (deg)')
  end
else
  p.planetMap      = planet.planetMap;
  p.planetColorMap = planet.planetColorMap;
  p.radius         = planet.radius;
end

%--------------------------------------------------------------------------
% PSS internal file version information
%--------------------------------------
% $Date: 2015-02-23 15:00:48 -0500 (Mon, 23 Feb 2015) $
% $Revision: 39671 $
