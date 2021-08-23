classdef ReferenceSystemTransformer
    properties
    end
    methods
        function num_x = x(tg_p, cr_p)
            err_x = tg_p(1) - cr_p(1);
            err_y = tg_p(2) - cr_p(2);
            num_x = err_x * cos(cr_p(4)) + err_y * sin(cr_p(4));
        end
        
        function num_y = y(tg_p, cr_p)
            err_x = tg_p(1) - cr_p(1);
            err_y = tg_p(2) - cr_p(2);
            num_y = err_y * cos(cr_p(4)) + err_x * sin(cr_p(4));
        end
    end
end