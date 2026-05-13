function theta = theta_calc(faces, face1, face2, phi)
    % This function calculates the angle theta based on the faces receiving sunlight and the angle phi.
    %
    % faces: Each position of the vector is one face of the satellite.
    %        The vector has 6 positions, from 1 to 6.
    %
    %        [  +Zpower   ,  -Zpower   ,  +Xpower   ,  +Ypower   ,  -Xpower   ,  -Ypower   ]
    %              1            2            3            4            5           6
    %
    % face1: One of the faces receiving sunlight.
    % face2: The other face receiving sunlight.
    % phi: The angle phi calculated previously.
    %
    % theta: The calculated angle in radians.

    if face1 == 1  % +Z
        if phi > pi
            theta = -atan(sqrt(faces(face2)/faces(face1))/sin(phi));
        else
            theta = atan(sqrt(faces(face2)/faces(face1))/sin(phi));
        end
        
    else  % -Z (face1 == 2)
        aux=atan(sqrt(faces(face2)/faces(face1))/sin(phi));
        if aux<0
            theta=pi+aux;
        else
            theta=pi-aux;
        end
    end
end

