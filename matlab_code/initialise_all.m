function initialise_all()
% MAIN FILE, THAT INITIALIZES AND DEFINES ENVIRONMENT

% LIST OF GLOBAL VARIABLES STORED AND INITIALIZED IN THIS CODE:
% 1) takeoff -> publisher from taking off
% 2) land -> publisher from landing
% 3) loop_trigger -> publisher that sends empty message - it triggers main steering function
% 4) control loop -> subscriber that starts main flying function
% 5) pose_getter -> subscriber responsible for acquiring drone's odometry data with 55-60 Hz frequency
% 6) current_pos -> container, where drone's current position is stored
% 7/8) target_pos / target_pos_norm -> container that keeps coordinates which drone has to reach
% 9) move -> publisher that sets proper velocities

            disp('Drone connected, ready to go')
            global takeoff; global land; global move; global pose_getter;
            global current_pos; global loop_trigger; global control_loop;            
            global target_pos; global target_pos_norm;
                       
            current_pos = [0;0;0;0];
            target_pos = [0;0;0;0];
            target_pos_norm = [0;0;0;0];
            pose_getter = rossubscriber('/repeater/bebop2/pose/info', @odom_callback);
            takeoff = rospublisher('/bebop/takeoff', 'std_msgs/Empty');
            land = rospublisher('/bebop/land', 'std_msgs/Empty');
            move = rospublisher('bebop/cmd_vel', 'geometry_msgs/Twist');
            loop_trigger = rospublisher('goToGoal', 'std_msgs/Empty');
            control_loop = rossubscriber('goToGoal', 'std_msgs/Empty', @go2goal);            
end
