    SunVectorECI('initialize', 'earth' );
    % (M10) FIX: 'initialize' is a one-time setup call; invoking it every step
    %            is wasteful. Move this line before the for loop in NadirPointing.m.
    %            (Delete it here; add the equivalent in NadirPointing.m before the loop)
    d.rSunECI = SunVectorECI( 'update', d.jD0+t/86400,x(1:3)); % Cartesian
    d.rSunBody = QForm( x(7:10), d.rSunECI ); %Cartesian
    rSunBody_norm=d.rSunBody/norm(d.rSunBody);
    
    %Determine the faces pointing to the sun

    u = [0;0;1];
    CosTheta = max(min(real(dot(u,d.rSunBody))/(norm(u)*norm(d.rSunBody)),1),-1);
    theta_faces(1) = acos(CosTheta);

    u = [0;0;-1];
    CosTheta = max(min(real(dot(u,d.rSunBody))/(norm(u)*norm(d.rSunBody)),1),-1);
    theta_faces(2) = acos(CosTheta);

    u = [1;0;0];
    CosTheta = max(min(real(dot(u,d.rSunBody))/(norm(u)*norm(d.rSunBody)),1),-1);
    theta_faces(3) = acos(CosTheta);

    u = [0;1;0];
    CosTheta = max(min(real(dot(u,d.rSunBody))/(norm(u)*norm(d.rSunBody)),1),-1);
    theta_faces(4) = acos(CosTheta);

    u = [-1;0;0];
    CosTheta = max(min(real(dot(u,d.rSunBody))/(norm(u)*norm(d.rSunBody)),1),-1);
    theta_faces(5) = acos(CosTheta);

    u = [0;-1;0];
    CosTheta = max(min(real(dot(u,d.rSunBody))/(norm(u)*norm(d.rSunBody)),1),-1);
    theta_faces(6) = acos(CosTheta);

for i = 1:length(theta_faces)
    % Check if the face is illuminated (angle of incidence < 90 degrees)
    if theta_faces(i) < pi/2
       point_faces(i,:) = theta_faces(i); 
        faces_temp(i,:) = 50; % Set a constant value for illuminated faces
    else
        point_faces(i,:) = pi/2; % Face is not illuminated
        faces_temp(i,:) = 0; % Set output to 0 for non-illuminated faces
    end
end 
    %Solar flux
    solar_flux = 1361; %  W/m²
    % (M4) FIX: CubeSatEnvironment uses 1367 W/m²; align both to the same
    %            solar constant. ~0.4 % numerical mismatch in sun-sensor model.
    % solar_flux = 1367; %  W/m² (consistent with CubeSatEnvironment)

    %Vo computations
    surface_ph = 2.7 *10^(-6); %m^2
    RL = 2000; %Ohm
    inc_power = solar_flux*surface_ph;
    ph_spectral_dens = 0.55; % A/Wepsilon_GaAs
    intensity_ph = ph_spectral_dens*inc_power;
    vo_ph = intensity_ph*RL;

    %Generate the noise of the photodiodes
    
    noise1 = normrnd(0, Sensors.sunSensors.sigmaNoise);
    noise2 = normrnd(0, Sensors.sunSensors.sigmaNoise);
    noise3 = normrnd(0, Sensors.sunSensors.sigmaNoise);
    
    faces_no_noise = vo_ph*cos(point_faces).^2 ;
    % (M3) FIX: Standard photodiode response is first-order cosine (Lambert's law).
    %            Squaring halves illumination at off-axis incidence.
    % faces_no_noise = vo_ph * cos(point_faces);
    faces_noise1=faces_no_noise+abs(noise1).';
    faces_noise2=faces_no_noise+abs(noise2).';
    faces_noise3=faces_no_noise+abs(noise3).';

    faces_noise=(faces_noise1+faces_noise2+faces_noise3)/3;
    phododiodes_meas_av(:,k) = faces_noise;

    
    sun_pos_compare(:,k)= d.rSunBody/norm(d.rSunBody);
    [aphi, atheta, ar] = cart2sph(rSunBody_norm(1),rSunBody_norm(2),rSunBody_norm(3));
    aphi=aphi*180/pi;
    atheta=atheta*180/pi;
  
    if atheta<0 && atheta== -90
        atheta=180;

    elseif atheta<0
        atheta=abs(-90+atheta);

    elseif atheta>0 && atheta==90
        atheta=0;

    elseif atheta>0
        atheta=90-atheta;

    else
        atheta=90;
    end
    
    sun_position(:,k)= sun_position_estimator(faces_noise, faces_temp);
    d.rSunBody = [sun_position(1,k);sun_position(2,k);sun_position(3,k)];