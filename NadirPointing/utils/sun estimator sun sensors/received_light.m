function [light] = received_light(theta_sun, phi_sun, cartesian_sun,cartesian_sat)
%Read the sensors information and parameters
    Sensors_Config_File;
    %Define variables
    light=zeros(1,6); %Vector that stores the recevied light
    faces=zeros(1,6); %Vector that stores the faces receiving light 1= light 0 = no light

    %Check if we are in eclipse
    [n,eclipse_type] = Eclipse( cartesian_sat, cartesian_sun );
    %Return 0 light in each photodiode if we are in eclipse
    if eclipse_type~= 0
        return
    end

    %Compute the angles
    x_angle=acosd(sind(theta_sun)*cosd(phi_sun));
    y_angle=acosd(sind(theta_sun)*sind(phi_sun));
    z_angle=acosd(cosd(theta_sun));

    minusx_angle=acosd(-sind(theta_sun)*cosd(phi_sun));
    minusy_angle=acosd(-sind(theta_sun)*sind(phi_sun));
    minusz_angle=acosd(-cosd(theta_sun));

    %Decide the faces [x,-x,y,-y,z,-z]

    if(x_angle < 90 && x_angle > -90)
        faces(1)=1;
        faces(2)=0;
    elseif(minusx_angle > 90 && minusx_angle < -90)
        faces(1)=0;
        faces(2)=1;
    end

    
    if(y_angle < 90 && y_angle > -90)
        faces(3)=1;
        faces(4)=0;
    elseif(minusy_angle > 90 && minusy_angle < -90)
        faces(3)=0;
        faces(4)=1;
    end


    if(z_angle < 90 && z_angle > -90)
        faces(5)=1;
        faces(6)=0;
    elseif(minusz_angle > 90 && minusz_angle < -90)
        faces(5)=0;
        faces(6)=1;
    end

    for pos=1:6
        if(faces(pos) == 1)
            switch(pos)
                case 1 
                    incx=90-x_angle;
                    light(pos)=Sensors.sunSensors.V0(pos)*cosd(incx)^2;
                case 2
                    incy=90-y_angle;
                    light(pos)=Sensors.sunSensors.V0(pos)*cosd(incy)^2;
               case 3
                    incz=90-z_angle;
                    light(pos)=Sensors.sunSensors.V0(pos)*cosd(incz)^2;
               case 4
                    incx=90-minusx_angle;
                    light(pos)=Sensors.sunSensors.V0(pos)*cosd(incx)^2;
               case 5
                    incy=90-minusy_angle;
                    light(pos)=Sensors.sunSensors.V0(pos)*cosd(incy)^2;
                otherwise
                    incz=90-minusz_angle;
                    light(pos)=Sensors.sunSensors.V0(pos)*cosd(incz)^2;
            end

        end

    end

    

end
