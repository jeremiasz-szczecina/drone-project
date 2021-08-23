function set_mission()
global loop_trigger; 
set_mission_msg = rosmessage(loop_trigger);
send(loop_trigger, set_mission_msg);
end