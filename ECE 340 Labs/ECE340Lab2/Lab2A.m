clear;
clc;

%Setup variables.
xk = 4;
hk = 3;
x = [0:xk];
h = 2 - [0:hk];

%Plot x[k].
subplot(2,2,1);
stem([0:length(x)-1],x);
title('x[k] response');
ylabel('x[k]');
xlabel('k');

%Plot h[k].
subplot(2,2,2);
stem([0:length(h)-1],h);
title('h[k] response');
ylabel('h[k]');
xlabel('k');

y = conv(x, h);

%Plot y[k].
subplot(2,2,3);
stem([0:length(y)-1],y);
title('y[k] response');
ylabel('y[k]');
xlabel('k');