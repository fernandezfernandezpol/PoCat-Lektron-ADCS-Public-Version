function face = real_orthogonal_2faces(faces_temp, face1, face2)
    % This function determines which one of two faces is the one receiving
    % sunlight and which one is the one receiving the albedo.
    %
    % faces_temp: Each position of the vector is one face of the satellite.
    %             The vector has 6 positions, from 1 to 6.
    %
    %             [  +Ztemperature   ,  -Ztemperature   ,  +Xtemperature   ,  +Ytemperature   ,  -Xtemperature   ,  -Ytemperature   ]
    %                   1                   2                  3                  4                  5                 6
    %
    %             In each position will be stored the temperature of each
    %             outer board.
    %
    % face1: One of the orthogonal faces.
    % face2: The second orthogonal face.
    %
    % face: The face that is receiving sunlight (either face1 or face2).

    % Storage of the temperature of each orthogonal face
    temp1 = faces_temp(face1);
    temp2 = faces_temp(face2);

    % Using the temperature, we determine which one is receiving the albedo and
    % which one is receiving the sunlight
    if temp1 > temp2
        % Face 1 is receiving the sunlight
        face = face1;
    else
        % Face 2 is receiving sunlight
        face = face2;
    end
end

