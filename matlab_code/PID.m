%PID-controller class
classdef PID
    properties
        % PID gains
        kp
        ki
        kd       
        % vector of base velocities
        max_param_value
        % errors_list's is a cell, container for vectors of different size (for each axis + yaw angle)
        % that store steady-state errors calculated during flight
        errors_list
        % 1x4 vector, contains number of errors calculated for each axis and yaw angle
        errors_count
        s {mustBeNumeric}
    end
    
    methods
        % default constructor with parameters used in the project
       function obj = PID()
            obj.kp = [1.03 1.03 6.4 0.9]; %x y z yaw
            obj.ki = [0.002 0.002 0.0001 0.0002]; %x y z yaw
            obj.kd = [60 60 34 6]; %x y z yaw
            obj.max_param_value = [1.0 1.0 1.0 1.0];
            obj.errors_list = { [0.0 0.0] [0.0 0.0] [0.0 0.0] [0.0 0.0] };
            obj.errors_count = [2 2 2 2];
            obj.s = 0.0;
       end        
        
       % function that calculates and returns velocity based on distance between drone's position and its distance to target
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
        
        function obj = reset_errors_list(obj)
            obj.errors_list = { [0.0 0.0] [0.0 0.0] [0.0 0.0] [0.0 0.0] };
            obj.errors_count = [2 2 2 2];
            obj.s = 0.0;
        end
                    
        function obj = insert_error_value_pair(obj, param, value_set, value_read)
            item_no = determine_param(param);
            v = value_set - value_read;
            obj.errors_list{item_no} = [obj.errors_list{item_no}, v];
            obj.errors_count(item_no) = obj.errors_count(item_no) + 1;
        end
    end
end
