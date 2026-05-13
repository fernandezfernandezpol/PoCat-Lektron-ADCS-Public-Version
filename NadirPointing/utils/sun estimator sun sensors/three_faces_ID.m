function [face1, face2, face3] = three_faces_ID(faces)
    % This function determines which 3 faces are receiving sunlight. It is already known that
    % there are only three faces receiving sunlight.
    %
    % faces: Each position of the vector is one face of the satellite.
    %        The vector has 6 positions, from 1 to 6.
    %
    %        [  +Zpower   ,  -Zpower   ,  +Xpower   ,  +Ypower   ,  -Xpower   ,  -Ypower   ]
    %              1            2            3            4            5           6
    %
    %        In each position will be stored the received power from
    %        the photodiodes of all outer boards.
    %
    % face1: Variable that stores the ID of the first face receiving sunlight.
    % face2: Variable that stores the ID of the second face receiving sunlight.
    % face3: Variable that stores the ID of the third face receiving sunlight.

    face1 = 0;  % Initialize the variable to store the first face ID
    face2 = 0;  % Initialize the variable to store the second face ID
    face3 = 0;  % Initialize the variable to store the third face ID
    n_face = 0; % Counter to track the number of faces detected

    % This loop traverses the faces array searching for the faces that receive sunlight
    for i = 1:6
        % If the position of the array is different from zero, it means that face is receiving sunlight
        if faces(i) ~= 0
            % Condition used to determine if the face detected is the first, the second, or the third one
            if n_face == 0
                % The position of the face is stored in face1
                face1 = i;
                % The counter n_face is increased by a unit to make sure that the following detected face is stored in face2
                n_face = n_face + 1;
            elseif n_face == 1
                % The position of the face is stored in face2
                face2 = i;
                % The counter n_face is increased by a unit to make sure that the following detected face is stored in face3
                n_face = n_face + 1;
            else
                % Store the face position in the variable face3
                face3 = i;
                % As the three faces have already been identified, the loop ends
                break;
            end
        end
    end
end

