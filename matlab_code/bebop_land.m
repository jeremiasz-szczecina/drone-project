function bebop_land()
global land
land_msg = rosmessage(land);
send(land, land_msg);
disp('Bebop - land')
end