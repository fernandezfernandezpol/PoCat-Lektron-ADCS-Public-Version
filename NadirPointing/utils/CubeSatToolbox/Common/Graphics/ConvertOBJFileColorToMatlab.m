function d = ConvertOBJFileColorToMatlab( m )

%--------------------------------------------------------------------------
%   Converts the Wavefront OBJ color format to Matlab.
%   Edge color is set equal to face color
%
%   Since version 8.
%--------------------------------------------------------------------------
%   Form:
%   d = ConvertOBJFileColorToMatlab( m )
%--------------------------------------------------------------------------
%
%   ------
%   Inputs
%   ------
%   m            (1,1) Material file data structer
%                        .Kd    (1,3) Diffuse reflectivity
%                        .Ks    (1,3) Specular reflectivity
%                        .Ka    (1,3) Ambient reflectivity
%                        .Ns    (1,3) Specular exponent
%                        .illum (1,3) Illumination model (not used)
%                        .d     (1,1) Transparency
%
%   -------
%   Outputs
%   -------
%   d            (1,1) Matlab color
%                        .faceColor                (1,3) Color of faces
%                        .edgeColor                (1,3) Color of edges
%                        .diffuseStrength          (1,1)
%                        .specularStrength         (1,1)
%                        .ambientStrength          (1,1)
%                        .specularExponent         (1,1)
%                        .specularColorReflectance (1,1)
%                        .faceAlpha                (1,1) Alpha channel
%
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
%   Copyright (c) 2009 Princeton Satellite Systems, Inc.
%   All rights reserved.
%--------------------------------------------------------------------------


d.faceColor        = m.Ka;
d.ambientStrength  = 1;
d.diffuseStrength  = norm(m.Kd)/norm(m.Ka);
d.specularStrength = norm(m.Ks)/norm(m.Ka);
d.edgeColor        = d.faceColor;
d.specularExponent = m.Ns;
d.faceAlpha        = m.d;   
d.specularColorReflectance = 1;


%--------------------------------------
% PSS internal file version information
%--------------------------------------
% $Date: 2015-03-13 12:29:00 -0400 (Fri, 13 Mar 2015) $
% $Revision: 39887 $
