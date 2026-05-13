function sun_position = sun_position_estimator(faces, faces_temp)
    % This function estimates the position of the sun based on the power and temperature data from the satellite faces.
    %
    % faces: Each position of the vector is one face of the satellite.
    %        The vector has 6 positions, from 1 to 6.
    %
    %        [  +Zpower   ,  -Zpower   ,  +Xpower   ,  +Ypower   ,  -Xpower   ,  -Ypower   ]
    %              1            2            3            4            5           6
    %
    % faces_temp: Each position of the vector is one face of the satellite.
    %            The vector has 6 positions, from 1 to 6.
    %
    %            [  +Ztemperature   ,  -Ztemperature   ,  +Xtemperature   ,  +Ytemperature   ,  -Xtemperature   ,  -Ytemperature   ]
    %                  1                   2                  3                  4                  5                 6
    %
    % sun_position: A 3-element vector representing the sun's position in
    %               the form [X component; Y component; Z component].

    for i=1:length(faces)
        if faces(i)<10^-(10)
            faces(i)=0;
        end
    end


    % Determine the number of faces that are receiving light
    faces_number = number_faces_pointing_sun(faces);

    % Initialize the sun position vector
    sun_position = zeros(3, 1);

    % CASE: ONLY 1 FACE RECEIVING LIGHT
    if faces_number == 1
        % Determine which is the face pointing to the sun
        sunface = face_pointing_sun(faces);
        % Estimate the position of the sun
        sun_position = sun_vector_1face(sunface);

    % CASE: ONLY 2 FACES RECEIVING LIGHT
    elseif faces_number == 2
        % Determine the two faces that are receiving light
        [face1, face2] = two_faces_ID(faces);
        % Determine if both faces are orthogonal
        if there_is_orthogonality(faces, face1, face2, 0) == 1
            % Determine which one of the two orthogonal faces is receiving the sunlight
            sunface = real_orthogonal_2faces(faces_temp, face1, face2);
            % Estimate the position of the sun
            sun_position = sun_vector_1face(sunface);
        else
            % Estimate the position of the sun
            sun_position = sun_vector_2faces(faces, face1, face2);
        end

    % CASE: ONLY 3 FACES RECEIVING LIGHT
    elseif faces_number == 3
        % Determine which 3 faces are receiving light
        [face1, face2, face3] = three_faces_ID(faces);
        % Check if two out of three faces are orthogonal
        if there_is_orthogonality(faces, face1, face2, face3) == 1
            % Determine the sun position
            sun_position = orthogonality_3faces_sunvector(faces, faces_temp, face1, face2, face3);
        else
            % Store the IDs of the faces receiving sunlight
            sunfaces = [face1, face2, face3];
            % Determine the sun position
            sun_position = sun_vector_3faces(faces, sunfaces);
        end

    % CASE: NO FACES RECEIVING SUNLIGHT
    elseif faces_number == 0
        sun_position = [0; 0; 0];

    % CASE: MORE THAN 3 FACES RECEIVING SUNLIGHT
    else
        % Initialize variables
        orthx = 0; orthy = 0; orthz = 0;
        count = 0; orth_cont = 0;
        activex = 0; activey = 0; activez = 0;
        no_orth_face = 0;
        sunfaces = zeros(1, 3);

        % Determine the number of orthogonal faces
        if faces(1) ~= 0 && faces(2) ~= 0
            orth_cont = orth_cont + 1;
            orthz = 1;
        elseif faces(1) ~= 0 || faces(2) ~= 0
            activez = activez + 1;
        end
        if faces(3) ~= 0 && faces(5) ~= 0
            orth_cont = orth_cont + 1;
            orthx = 1;
        elseif faces(3) ~= 0 || faces(5) ~= 0
            activex = activex + 1;
        end
        if faces(4) ~= 0 && faces(6) ~= 0
            orth_cont = orth_cont + 1;
            orthy = 1;
        elseif faces(4) ~= 0 || faces(6) ~= 0
            activey = activey + 1;
        end

        % Determine which faces are receiving sunlight
        if orthx == 1
            if faces_temp(3) > faces_temp(5)
                sunfaces(count + 1) = 3;
            else
                sunfaces(count + 1) = 5;
            end
            count = count + 1;
        elseif activex == 1
            if faces(3) ~= 0
                sunfaces(count + 1) = 3;
            else
                sunfaces(count + 1) = 5;
            end
            count = count + 1;
        end
        if orthy == 1
            if faces_temp(4) > faces_temp(6)
                sunfaces(count + 1) = 4;
            else
                sunfaces(count + 1) = 6;
            end
            count = count + 1;
        elseif activey == 1
            if faces(4) ~= 0
                sunfaces(count + 1) = 4;
            else
                sunfaces(count + 1) = 6;
            end
            count = count + 1;
        end
        if orthz == 1
            if faces_temp(1) > faces_temp(2)
                sunfaces(count + 1) = 1;
            else
                sunfaces(count + 1) = 2;
            end
            count = count + 1;
        elseif activez == 1
            if faces(1) ~= 0
                sunfaces(count + 1) = 1;
            else
                sunfaces(count + 1) = 2;
            end
            count = count + 1;
        end

        % Estimate the sun position
        if count == 2
            sun_position = sun_vector_2faces(faces, sunfaces(1), sunfaces(2));
        else
            sun_position = sun_vector_3faces(faces, sunfaces);
        end
    end
end