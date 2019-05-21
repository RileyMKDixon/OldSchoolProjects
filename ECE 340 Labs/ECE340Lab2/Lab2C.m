clear;
clc;

%Setup variables.
T1 = 1/100; %Sampling frequency
n1 = [0:30];
t1 = n1 .* T1;
y1k = cos(20*pi*t1);
y2k = cos(180*pi*t1);

%Plot y1[k].
subplot(2,1,1);
stem(y1k);
title('cos(20*pi*t) sampled at 100Hz');
ylabel('y1[k]');
xlabel('k');

%Plot y2[k].
subplot(2,1,2);
stem(y2k);
title('cos(180*pi*t) sampeld at 100Hz');
ylabel('y2[k]');
xlabel('k');

%They are identical as expected. if X1 = X2 + 2*pi*n for some integer n
%the signals cannot be distinguished from one another. n = -1 for this case.

disp('Press any key to continue.');
pause();
close();

%2nd part of Lab2C
%Setup variables
T2 = 1/1000;
n2 = [0:300];
t2 = n2 .* T2;
z1k = cos(20*pi*t2);
z2k = cos(180*pi*t2);

%Code copied and modified out of the lab manual.
subplot(2,1,1);
plot(n2*T2,z1k,'r-', n1*T1,y1k,'b+'); 
xlabel('n');
ylabel('y_1[n] and z_1[n]'); 
legend('z_1[n]','y_1[n]');
subplot(2,1,2);
plot(n2*T2,z2k,'r-', n1*T1,y2k,'b+');
xlabel('n');
ylabel('y_2[n] and z_2[n]'); 
legend('z_2[n]','y_2[n]');

%z1k and y1k match up perfect and provide an accurate sampling rate.
%y2k however is sampled less frequently than it should be as shown by
%the graph z2k. Even though y1k and y2k appear identical discretely,
%z1k and z2k clearly show that their continuous signal counterparts 
%are different.

disp('Press any key to continue.');
pause();
close();
%Close the figure to setup for the 2nd part

%3rd part of Lab2C

%Let omega = 220, thus n = -1.
%Trick: Add or subtract by a multiple of 200 from 20.
y3k = cos(220*pi*t1);

%Plot the original y1[k].
subplot(2,1,1);
stem(y1k);
title('cos(20*pi*t) sampled at 100Hz');
ylabel('y1[k]');
xlabel('k');

%Plot the new y3[k].
subplot(2,1,2);
stem(y3k);
title('cos(2200*pi*t) sampeld at 100Hz');
ylabel('y3[k]');
xlabel('k');
