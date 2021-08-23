function plot_data()
data = dlmread('tracking.txt', ' ');
%data = dlmread('points.txt', ' ');
siz = size(data);
t_k = siz(1);
Tp = 1/90;

t = [0: Tp: t_k*Tp - Tp];
figure(1)
subplot(2,1,1)
plot(t, data(:,1)); hold on; plot(t, data(:,2)); hold on; plot(t, data(:,3));
title('Zadana trajektoria i przelot, os X')
ylabel('Obecna/zadana pozycja')
xlabel('t [s]; f_s = 90 Hz')
legend('target pos', 'target pos norm', 'current pos')
grid on;

subplot(2,1,2)
plot(t, data(:,4)); hold on; plot(t, data(:,5)); hold on; plot(t, data(:,6));
title('Zadana trajektoria i przelot, os Y')
ylabel('Obecna/zadana pozycja')
xlabel('t [s]; f_s = 90 Hz')
legend('target pos', 'target pos norm', 'current pos')
grid on;

figure(2)
subplot(2,1,1)
plot(t, data(:,7)); hold on; plot(t, data(:,8));
title('Zadana trajektoria i przelot, os Z')
ylabel('Obecna/zadana pozycja')
xlabel('t [s]; f_s = 90 Hz')
legend('target pos', 'current pos')
grid on;

subplot(2,1,2)
plot(t, data(:,9)); hold on; plot(t, data(:,10));
title('Zadana trajektoria i przelot, kat YAW')
ylabel('Obecna/zadana pozycja')
xlabel('t [s]; f_s = 90 Hz')
legend('target pos', 'current pos')
grid on;
end