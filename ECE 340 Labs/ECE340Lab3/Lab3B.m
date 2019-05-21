clear;
clc;

%Coffecients of the polynomial
H1N = [2, 2];
H1D = [1, -1.25];
H2N = [2, 2];
H2D = [1, -0.8];

subplot(1,2,1);
%[z1, p1, k1] = tf2zpk(H1N, H1D);
zplane(H1N, H1D);
title('H1');
ylabel('Imaginary Part');
xlabel('Real Part');
%pole at x=1.25
%zero at x=-1
%Unstable as pole is >1 or in other words outside of the ROC
subplot(1,2,2);
%[z2, p2, k2] = tf2zpk(H2N, H2D);
zplane(H2N, H2D);
title('H2');
ylabel('Imaginary Part');
xlabel('Real Part');
legend('ROC', 'Poles', 'Zeros');
%pole at x=0.8
%zero at x=-1
%Stable as pole is <1 or in other words is inside the ROC

%Part B
figure(2);

%Setup  variables
omega = linspace(0, 2*pi);
z = exp(j * omega);
H1omega = (2 + 2 .*z.^-1)./(1 - 1.25 .*z.^-1);
H2omega = (2 + 2 .*z.^-1)./(1 - 0.8 .*z.^-1);
%Seperate the complex array into it's phasor parts
H1omegaMag = abs(H1omega);
H1omegaAng = angle(H1omega);
H2omegaMag = abs(H2omega);
H2omegaAng = angle(H2omega);

%Plot H1
subplot(1,2,1);
stem(H1omegaMag);
hold on;
stem(H2omegaMag, 'Marker', 'square');
title('Magnitude of Frequency Response');
xlabel('omega');
ylabel('Magnitude of H(omega)');
legend('H1', 'H2');

%Plot H2
subplot(1,2,2);
stem(H1omegaAng);
hold on;
stem(H2omegaAng, 'Marker', 'square');
title('Angle of Frequency Response');
xlabel('omega');
ylabel('Angle of H(omega)');
legend('H1', 'H2');

%Part C
figure(3);

%Setup variables
n = [0:25];
%skip n=0 for second terms
h1 = 2*(5/4).^n + 2*(5/4).^(n-1).*[0, ones(1,25)];
h2 = 2*(4/5).^n + 2*(4/5).^(n-1).*[0, ones(1,25)];

%Plot the time domain h[n] to verify convergence from part a
stem(n, h1);
hold on;
stem(n, h2, 'Marker', 'square');
title('h1 and h2');
ylabel('h[n] response');
xlabel('''n'' input');
legend('h1', 'h2');