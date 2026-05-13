function sun_position = orthogonality_3faces_sunvector(faces, faces_temp, face1, face2, face3)
    pairs = [1 2; 3 5; 4 6]; % Definir las parejas ortogonales de caras

    % Recorre todas las parejas ortogonales posibles
    for i = 1:size(pairs, 1)
        % Verifica si face1 y face2, face2 y face3, o face1 y face3 son ortogonales
        if all(ismember([face1, face2], pairs(i, :)))
            sunface = real_orthogonal_2faces(faces_temp, face1, face2);
            sun_position = sun_vector_2faces(faces, sunface, face3);
            return;
        elseif all(ismember([face2, face3], pairs(i, :)))
            sunface = real_orthogonal_2faces(faces_temp, face2, face3);
            sun_position = sun_vector_2faces(faces, sunface, face1);
            return;
        elseif all(ismember([face1, face3], pairs(i, :)))
            sunface = real_orthogonal_2faces(faces_temp, face1, face3);
            sun_position = sun_vector_2faces(faces, sunface, face2);
            return;
        end
    end
end

