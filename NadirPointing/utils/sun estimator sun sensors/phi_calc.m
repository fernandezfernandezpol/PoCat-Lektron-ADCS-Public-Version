function phi = phi_calc(faces, face1, face2)
    % This function calculates the angle phi based on the faces receiving sunlight.
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
    % phi: The calculated angle in radians.


    % Calculate the sum of the face indices
    sum_faces = face1 + face2;

    % Calculate phi based on the sum of the face indices
    switch sum_faces
        case 7  % Equivalent to sum = 5 in C (2+3)
            phi = atan(sqrt(faces(face2) / faces(face1)));
        case 11  % Equivalent to sum = 9 in C (4+5, etc.)
            phi = pi + atan(sqrt(faces(face2) / faces(face1)));
        otherwise
            if face1 == 3  % Equivalent to face2 = 6 in C (+X)
                phi = 2*pi - atan(sqrt(faces(face2) / faces(face1)));
            else
                phi = pi - atan(sqrt(faces(face2) / faces(face1)));
            end
    end
end
