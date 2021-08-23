function bebop_takeoff()
global takeoff
takeoff_msg = rosmessage(takeoff);
send(takeoff, takeoff_msg);
disp('Bebop - takeoff')
end