function [eclipse] = Eclipse_Check(xsat_eci, sun_eci, eclipseOn,dESm)

%Eclipse_ECSM: Earth Conical Shadow Model. This function returns the
%eclipse state of the satellite. 
%0 - Sunlite (no eclipse)
%1 - Penumbra (partial eclipse)
%2 - Umbra (total eclipse)

%INPUT
%xsat_eci: satellite's position in ECI frame referenced to J2000
%sun_eci: sun unit vector in ECI frame referenced to J2000

%OUTPUT
%eclipse: vector containing the values 0,1 or 2 on each position of the
%satellite.


%Orbital points
npts=length(xsat_eci);

eclipse=zeros(npts,1);
Re = 6.378137*10^6; %Earth equatorial radius [m]
Rs = 6.96342*10^8;%Sun mean radius [m] from SOHO (2003-2006) results
AU = 1.49597870700*10^11; %Astronomical Unit - sun-earth mean distance [m]


%Calculation of sun-earth distance (dSE)[N x 1]
% sun_norm=((sun_eci(:,1).^2 + sun_eci(:,2).^2 + sun_eci(:,3).^2).^0.5);
% dSE = sun_norm.*AU;
  dSE = dESm;
if eclipseOn == 1
    
    for i=1:npts
    
    dot_sun= dot(xsat_eci(:,1),sun_eci(:,1));

    % CASE 1.1: Sunlit State before the normal plane to the sun vector passing through
    % Earth's center of mass
        if(dot_sun >= 0)
    
        eclipse(i,1)= 0;
        else
   
            p = dot_sun*sun_eci(i,:);
            q = xsat_eci(1,:) - p;
        
            Xu= Re*dSE(i,1)/(Rs-Re);
            Xp = Re*dSE(i,1)/(Rs+Re);
    
            alpha = asin((Rs-Re)/dSE(i,1));
            beta = asin((Rs+Re)/dSE(i,1));
    
            du = (Xu-norm(p))*tan(alpha);
            dp = (Xp+norm(p))*tan(beta);
          
        % CASE 1.2: Sunlit State behind the normal plane to the sun vector passing through
        % Earth's center of mass

            if (norm(q) >= dp)
        
            eclipse(1,i)=0;
        
        % CASE 2: Penumbra State   
            elseif (du < norm(q) && norm(q) < dp)
                eclipse(:,i)=1;
        
        % CASE 3: Umbra State    
            elseif (norm(q) < du)
        
                eclipse(:,i)=2;
                
            end
                
        
        end
   
    end
    
end

end