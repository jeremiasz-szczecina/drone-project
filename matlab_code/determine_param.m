function num = determine_param(param)
% function that allows to reach (later in the code) particular axis, by simply passing string argument
% rather than integer; way more intuitive
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
