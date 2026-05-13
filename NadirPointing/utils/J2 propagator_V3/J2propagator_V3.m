clear;clc;
%%Obtain orbital elements using the TLE
TLE = getSatelliteTLE();
OE = TLE2OrbitalElements(TLE);

%%Constants
J2=1.083e-3;
mu = 398600.4418; % km^3/s^2
R_E = 6378.137; % km

%Desired time to propagate
t_totalh=12*1;  %hours
t_totals=t_totalh*3600; %s
dt=0.5; %s
n_steps = floor(t_totals / dt);
t=(0:dt:t_totals);t=t(1:length(t)-1);

%Orbital initial parameters
e=OE.e;
a=OE.a_km;%km
i=deg2rad(OE.i_deg);
OmegaJ2=deg2rad(OE.Omega_deg);
omegaJ2=deg2rad(OE.omega_deg);
MJ2=deg2rad(OE.M_deg);

% Mean motion from TLE in rev/day, convert to rad/s
n_rev_per_day = OE.n_orbits_per_day; % rev/day
n = n_rev_per_day * (2 * pi) / 86400; % rad/s

%Secular parameters
factor=(J2*R_E^2)/((1-e^2)^2)*sqrt(mu/a^7);
Omegasecular=-3/2*factor*cos(i);
omegasecular=3/4*factor*(5*cos(i)^2-1);

%perturbations
Omega_moon=-0.00338*cos(i)/n;
omega_moon=0.00169*(5*(cos(i))^2-1)/n;
Omega_sun=-0.00154*cos(i)/n;
omega_sun=0.00077*(5*(cos(i))^2-1)/n;

%Newton's solution parameters
tol=1e-8;
n_ite=1000;


for step=1:n_steps
    %Solve kepler's equation
    [E,converged] = kepler_equation_newton(MJ2,e,n_ite,tol);
    if ~converged
            warning('No se pudo propagar más debido a la falta de convergencia en Newton-Raphson');
            break;
    end
    %True anomaly computation
    E_vec(step) = E;
    theta=2*atan(sqrt((1+e)/(1-e))*tan(E/2));
    theta_vec(step)=theta;
    %Periferal constants
    pos_cnst=(a*(1-e^2))/(1+e*cos(theta));
    vel_cnst=sqrt(mu/(a*(1-e^2)));
    %Periferal frame
    x_periferial = [pos_cnst*cos(theta);pos_cnst*sin(theta);0];
    v_periferal = [-vel_cnst*sin(theta);vel_cnst*(e+cos(theta));0];
    %Convert to ECI frame
    [x_ECI(:,step)] = periferal_to_ECI(x_periferial,omegaJ2,OmegaJ2,i);
    [v_ECI(:,step)] = periferal_to_ECI(v_periferal,omegaJ2,OmegaJ2,i);

    %Update the orbital elements
    % OmegaJ2=OmegaJ2+(Omegasecular+Omega_sun+Omega_moon)*dt;
    OmegaJ2=OmegaJ2+(Omegasecular)*dt;
    Omega_vec(step)=OmegaJ2;
    % omegaJ2=omegaJ2+(omegasecular+omega_sun+omega_moon)*dt;
    omegaJ2=omegaJ2+(omegasecular)*dt;
    omega_vec(step)=omegaJ2;
    MJ2=MJ2+n*dt;
    MJ2_vec(step)=MJ2;

end

% *Plot Cartesian Coordinates*
figure('color','white');
plot3(x_ECI(1,:),x_ECI(2,:),x_ECI(3,:))
xlabel('ECI x [m]');
ylabel('ECI y [m]');
zlabel('ECI z [m]');
title('Satellite Orbit in ECI Coordinates');
grid on

figure
plot(Omega_vec);
title('Omega');

figure
plot(omega_vec);
title('omega');


figure
plot(t,MJ2_vec);
title('M');


figure
plot(theta_vec);
title('theta');

figure
plot(E_vec);
title('E kepler');

figure
plot(t/3600,x_ECI(1,:));
title('X component position');

function [E,converged] = kepler_equation_newton(M,e,n_ite,tol)
%Initial parameters
    E=M;
    converged=false;
    ite=0;
%Limitate the iterations for optimization of the code
    while(n_ite>ite)
        g=E-e*sin(E)-M;
        gder=1-e*cos(E);
        Enext=E-g/gder;
%Limitator
        if(abs(Enext-E)<tol)
            E=Enext;
            converged=true;
            break;
        end
        E=Enext;
        ite=ite+1;
    end
end

function [vector_ECI] = periferal_to_ECI(vector_periferal,o,O,i)
    
    matrix=[cos(O)*cos(o)-sin(O)*cos(i)*sin(o),-cos(O)*sin(o)-sin(O)*cos(i)*cos(o),sin(O)*sin(i);...
        sin(O)*cos(o)+cos(O)*cos(i)*sin(o),-sin(O)*sin(o)+cos(O)*cos(i)*cos(o),-cos(O)*sin(i);...
        sin(i)*sin(o),sin(i)*cos(o),cos(i)];

    vector_ECI=matrix*vector_periferal;
end
