clear;

k1 = [-10:40];
k2 = [0:100];
x1 = -5.1*sin(0.1*pi*k1 - 3*pi/4) + 1.2*cos(0.4*pi*k1);
x2 = (-0.9).^k2 .* exp(j*pi*k2/10);
x2R = real(x2);
x2I = imag(x2);

g = subplot(2,2,1);
stem(k1, x1);
text(10, 1, 'x1 Period: 20');
title('x1 vs k');
xlabel('k');
ylabel('x1 signal magnitude');

subplot(2,2,2);
stem(k2, x2R);
title('x2 Real Part');
ylabel('x2 signal magnitude');
xlabel('k');

subplot(2,2,3);
stem(k2, x2I);
title('x2 Imaginary Part');
ylabel('x2 signal magnitude');
xlabel('k');


x1Energy = sum(abs(x1).^2);
x2Energy = sum(abs(x2).^2);