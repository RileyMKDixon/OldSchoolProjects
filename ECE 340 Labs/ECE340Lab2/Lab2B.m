clear;
clc;

%Setup variables.
k = [0:50];
hk = (0.3*sin(0.3*(k - 25)*pi)./(k*pi)) .* (0.54 - 0.46*cos(2*pi*k/50));

%Plot h[k].
stem(hk);
title('h[k] response');
ylabel('h[k]');
xlabel('k');

%Load audiofile and convolve it with h[k].
balia = audioread('baila.wav');
balia_filtered = conv(hk, balia);

%Output the resulting audiofile.
audiowrite('balia_filtered.wav', balia_filtered, 44100);