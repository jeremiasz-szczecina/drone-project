function go2goal(~, message)

global target_pos;
global PID_error_locked; global RST_handler; global move;
global current_pos; global target_pos_norm;

fileID_track = fopen('tracking.txt','w');

loop_rate = rosrate(90);

move_msg = rosmessage('geometry_msgs/Twist');
move_msg.Linear.X = 0.0;
move_msg.Linear.Y = 0.0;
move_msg.Linear.Z = 0.0;
move_msg.Angular.X = 0.0;
move_msg.Angular.Y = 0.0;
move_msg.Angular.Z = 0.0;

RST_handler = ReferenceSystemTransformer();
target_pos = [0;0;0;0];

%WCZYTANIE PLIKU Z TRAJEKTORIAMI
waypoints = csvread('trajectories.csv'); %wczytanie wektora danych (x, 4)
siz = size(waypoints); %okreslenie rozmiaru
num_iterations = siz(1); %rozmiar jest 1x2, wiec wybranie ilosci wierszy

disp('Bebop has received a new task to do')

PID_error_locked = true;
%INICJALIZACJA REGULATORA PID
global PID_handler;
PID_handler = PID();
PID_error_locked = false;
disp('On a mission!')

pid_trigger = 0.01; %dokladnosc

for i = 1:num_iterations
    %zadawanie kolejnych koordynatow
    target_pos(1) = waypoints(i,1);
    target_pos(2) = waypoints(i,2);
    target_pos(3) = waypoints(i,3);
    target_pos(4) = waypoints(i,4);
    PID_handler = PID_handler.reset_errors_list();
    % bazowe domyslne predkosci - 100% zakresu okreslonego parametrem
    % max_param_value w klasie PID
    PID_resultX = 1.0;
    PID_resultY = 1.0;
    PID_resultZ = 1.0;
    PID_resultYAW = 1.0;
    loop_cond = 0;
    % petla sterujaca, nastepny obrot nastepuje po dotarciu do kolejnych
    % kooordynatow we WSZYSTKICH osiach
    while (abs(PID_resultX) > pid_trigger) || (loop_cond < 360) || (abs(PID_resultY) > pid_trigger) || (abs(PID_resultZ) > pid_trigger) || (abs(PID_resultYAW) > pid_trigger) 
        % obliczanie potrzebnej do zadania predkosci
        PID_resultX = PID_handler.calculate("X");
        PID_resultY = PID_handler.calculate("Y");
        PID_resultZ = PID_handler.calculate("Z");
        PID_resultYAW = PID_handler.calculate("YAW");
        move_msg.Linear.X = PID_resultX;
        move_msg.Linear.Y = PID_resultY;
        move_msg.Linear.Z = PID_resultZ;
        move_msg.Angular.Z = PID_resultYAW;
        % publikowanie wiadomosci Twist, by poruszyc UAV
        send(move, move_msg);
        waitfor(loop_rate);
        loop_cond = loop_cond + 1;
        % zapisywanie polozen do pliku
        fprintf(fileID_track, '%.2f %.2f %.2f %.2f %.2f %.2f %.2f %.2f %.2f %.2f\n', target_pos(1), target_pos_norm(1), current_pos(1), target_pos(2), target_pos_norm(2), current_pos(2), target_pos(3), current_pos(3), target_pos(4), current_pos(4));
    end
end

fclose(fileID_track);
disp('Done!')

end