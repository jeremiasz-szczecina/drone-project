%klasa regulatora PID
classdef PID
    properties
        %wzmocnienia
        kp
        ki
        kd       
        %wektor bazowych predkosci
        max_param_value
        %typ cell, zawiera rozne rozmiarowo wektory (dla kazdej z osi)
        %obliczanych uchybow podczas lotu
        errors_list
        %wektor 1x4, zawiera liczbe obliczonych bledow w kazdej osi
        errors_count
        s {mustBeNumeric}
    end
    
    methods
        %domyslny konstruktor z parametrami
       function obj = PID()
            obj.kp = [1.03 1.03 6.4 0.9]; %x y z yaw
            obj.ki = [0.002 0.002 0.0001 0.0002]; %x y z yaw
            obj.kd = [60 60 34 6]; %x y z yaw
            obj.max_param_value = [1.0 1.0 1.0 1.0];
            obj.errors_list = { [0.0 0.0] [0.0 0.0] [0.0 0.0] [0.0 0.0] };
            obj.errors_count = [2 2 2 2];
            obj.s = 0.0;
       end        
        
       %funkcja obliczajaca zadawana predkosc
        function result = calculate(obj,param)
            item_no = determine_param(param);
            
            if obj.errors_count(item_no) >= 2               
                U = (obj.kp(item_no) * obj.errors_list{item_no}(end)) + ...
                    (obj.kd(item_no) * (obj.errors_list{item_no}(end) - obj.errors_list{item_no}(end-1)));
                if ((obj.errors_list{item_no}(end-1) > obj.max_param_value(item_no)) && (obj.errors_list{item_no}(end) > 0)) || ((obj.errors_list{item_no}(end-1) < -obj.max_param_value(item_no)) && (obj.errors_list{item_no}(end) < 0))
                    obj.s = 0.0;
                else
                    obj.s = obj.s + obj.errors_list{item_no}(end);
                end
                
                result = U + (obj.ki(item_no) * obj.s);
                
                
                if result > obj.max_param_value(item_no)
                    result = obj.max_param_value(item_no);
                elseif result < -obj.max_param_value(item_no)
                    result = -obj.max_param_value(item_no);
                end
            end
        end
        
        % przykladowe wywolanie -> tst = tst.reset_errors_list()
        function obj = reset_errors_list(obj)
            obj.errors_list = { [0.0 0.0] [0.0 0.0] [0.0 0.0] [0.0 0.0] };
            obj.errors_count = [2 2 2 2];
            obj.s = 0.0;
        end
               
        % przykladowe wywolanie -> tst = tst.insert_error_value_pair("X", 10, 2)        
        function obj = insert_error_value_pair(obj, param, value_set, value_read)
            item_no = determine_param(param);
            v = value_set - value_read;
            obj.errors_list{item_no} = [obj.errors_list{item_no}, v];
            obj.errors_count(item_no) = obj.errors_count(item_no) + 1;
        end
    end
end