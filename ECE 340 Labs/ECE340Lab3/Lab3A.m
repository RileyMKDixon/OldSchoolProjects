clear;
clc;
clf;

n = [0:10];
h1 = n .* (0.5).^n .* sin(pi.*n/6);
%Part B

%Frequency scale followed by a differentiation
%As per the properties of the Z-Transform
%a^n*z[n] = Z(z/a)
%x*z[n] = -z*Z'(z) 
%N(z^-1) = -(1/4)*z^-2+(1/16)*z^-4
%D(z^-1) = 1-sqrt(3)*z^-1+(5/4)*z^-2-(sqrt(3)/2)*z^-3+(1/16)*z^-4

%Coeffcients of the polynomials
N = [0, 0, -1/4, 0, 1/16];
D = [1, -sqrt(3), (5/4), -sqrt(3)/2, 1/16];

%Part C
h2 = filter(N, D, n);

%Part D - plotting the results
stem(h1);
hold on;
h = stem(h2, 'Marker', 'square');
legend('h1', 'h2');
title('input ''h1'' vs output ''h2''');
xlabel('n');
ylabel('h[n]');
