function odom_callback(~, message)

global current_pos; global PID_error_locked; global PID_handler;
global target_pos; global target_pos_norm;

x_val = message.Pose.Pose.Position.X;
y_val = message.Pose.Pose.Position.Y;

yaw_val = quat2eul([message.Pose.Pose.Orientation.W message.Pose.Pose.Orientation.X ...  
    message.Pose.Pose.Orientation.Y message.Pose.Pose.Orientation.Z]);

current_pos(1) = x_val*cos(yaw_val(1)) + y_val*sin(yaw_val(1));
current_pos(2) = -x_val*sin(yaw_val(1)) + y_val*cos(yaw_val(1));
current_pos(3) = message.Pose.Pose.Position.Z;
current_pos(4) = yaw_val(1);

%normalizacja zadawanych polozen ze wzgledu na rozne uklady odniesienia
target_pos_norm(1) = (target_pos(1) * cos(current_pos(4))) + (target_pos(2) * sin(current_pos(4)));
target_pos_norm(2) = (-target_pos(1) * sin(current_pos(4))) + (target_pos(2) * cos(current_pos(4)));

if PID_error_locked == false
    PID_handler = PID_handler.insert_error_value_pair("X", target_pos_norm(1), current_pos(1));
    PID_handler = PID_handler.insert_error_value_pair("Y", target_pos_norm(2), current_pos(2));
    PID_handler = PID_handler.insert_error_value_pair("Z", target_pos(3), current_pos(3));
    PID_handler = PID_handler.insert_error_value_pair("YAW", target_pos(4), current_pos(4));
end
end