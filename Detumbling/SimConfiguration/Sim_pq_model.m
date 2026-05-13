%% PocketQube Geometry
% Returns face areas a, unit normals n, and face centroids r for a 0.5U PQ
% (5 cm × 5 cm × 5 cm). These are passed to the aero and optical disturbance
% models via d.surfData.
% cube = '1U';
cube    = [0.5, 0.5, 0.5];
[a,n,r] = CubeSatFaces( cube, 1 );
