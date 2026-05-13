 function Polarization2(xPlot, leff_sat, pol_ant_GS,lat_g,long_g)
%   ------
%   Inputs
%   ------
%   xPlot           
%   leff_sat        effective length of antenna in the satellite [l_eff_x, l_eff_y, l_eff_z]; l_eff_p = {+1, -1, +j, -j} to define an arbitrary polarization
%   pol_ant_GS:     defines poarization of ground station antenna: horizontal =
%                   [1 0], vertical: [0 1], LHCP = [1 +j]; RHCP = [1 -j]
%   lat_g           Latitude of the ground station
%   long_g          Longitude of the ground station
%


r_g = 6387.165*[cosd(lat_g)*cosd(long_g);cosd(lat_g)*sind(long_g);sind(lat_g)];
r=Unit(r_g);

for k=100:length(xPlot)

r_sat=xPlot(1:3,k);
    
m = Unit( Q2Mat(xPlot(7:10,k)) );
leff_sat = leff_sat./sqrt(sum(abs(leff_sat).^2));

leff_Cubesat=leff_sat(1).*m(1,:) + leff_sat(2).*m(2,:) + leff_sat(3).*m(3,:) ; %% Antena Vector (z axis)

h=(Cross(r,r_sat-r_g))./norm(r_sat-r_g);

v=(Cross(r_sat-r_g,h))./norm(r_sat-r_g);

leff_GS = pol_ant_GS(1).*h + pol_ant_GS(2).*v;

leff_GS = leff_GS./sqrt(sum(abs(leff_GS).^2));

Cpol(k)=norm(dot(leff_Cubesat,leff_GS)).^2;

end
figure;
plot(Cpol);

figure;
plot(10*log10(abs(Cpol)));
title('Loss in dB'); xlabel('Time [seconds]'); ylabel('Loss in dB');
 end
