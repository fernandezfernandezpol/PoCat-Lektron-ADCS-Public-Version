function sun_position = sun_vector_2faces(faces, face1, face2)
    % This function calculates the sun position vector based on two faces receiving sunlight.
    %
    % faces: Each position of the vector is one face of the satellite.
    %        The vector has 6 positions, from 1 to 6.
    %
    %        [  +Zpower   ,  -Zpower   ,  +Xpower   ,  +Ypower   ,  -Xpower   ,  -Ypower   ]
    %              1            2            3            4            5           6
    %
    % face1: One of the faces receiving sunlight.
    % face2: The other face receiving sunlight.
    %
    % sun_position: A 3-element vector representing the sun's position in
    %               the form [X component; Y component; Z component].



    % Initialize variables
    theta = 0;
    phi = 0;
    not_z = 0;
    z = 0;

    % Check if one of the faces is a Z face
    if ismember(face1, [1, 2]) || ismember(face2, [1, 2])
        % Identify which face is the Z face
        if ismember(face1, [1, 2])
            not_z = face2;
            z = face1;
        else
            not_z = face1;
            z = face2;
        end

        % Identify the other face receiving sun power and calculate phi
        switch not_z
            case 3  % +X
                phi = 0;
            case 4  % +Y
                phi = pi / 2;
            case 5  % -X
                phi = pi;
            otherwise  % -Y
                phi = 3 * pi / 2;
        end

        % Calculate theta using the theta_calc function
        theta = theta_calc(faces, z - 1, not_z - 1, phi);  % Adjust indices for theta_calc
    else
        % Both faces are non-Z faces
        theta = pi / 2;
        phi = phi_calc(faces, face1 - 1, face2 - 1);  % Adjust indices for phi_calc
    end

    % Calculate the sun position vector
    sun_position = [sin(theta) * cos(phi); sin(theta) * sin(phi); cos(theta)];
end