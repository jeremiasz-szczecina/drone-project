function initialise_all()
% GLOWNY PLIK, INICJALIZUJACY I DEFINIUJACY WSZYSTKO

% LISTA GLOBALNYCH ZMIENNYCH, INICJALIZOWANYCH W TYM KODZIE:
% 1) takeoff -> publisher od wznoszenia sie
% 2) land -> publisher od ladowania
% 3) loop_trigger -> publisher wysylajacy puste info-wyzwalacz do glownej
% funkcji sterujacej
% 4) control loop -> subscriber wyzwalajacy glowna funkcje latania
% 5) pose_getter -> subscriber pobierający dane z odometrii drona z f=56Hz
% 6) current_pos -> kontener, w ktorym przechowywane będą aktualne dane o
% pozycji drona
% 7/8) target_pos / target_pos_norm -> kontener, w ktorym przechowywane będą koordynaty do
% ktorych dron ma doleciec
% 9) move -> publisher od nadawania predkosci

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