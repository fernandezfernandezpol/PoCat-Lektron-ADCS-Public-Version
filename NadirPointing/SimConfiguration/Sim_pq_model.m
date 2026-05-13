%% Select the PocketQube type
% The face areas and normals are needed by the aero model.  They are given
% by the CubeSatFaces function.
% -------------------------------------------------------------------------
cube = '0.5U';
[a,n,r] = CubeSatFaces( cube, 1 );
