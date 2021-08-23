function num = determine_param(param)
% funkcja pozwalajaca okreslic odwolanie do konkretnej osi poprzez
% podawanie argumentu typu string oznaczajacego zadana os
            num = 0;
            if param == "X"
                num = 1;
            elseif param == "Y"
                num = 2;
            elseif param == "Z"
                num = 3;
            elseif param == "YAW"
                num = 4;
            end
end