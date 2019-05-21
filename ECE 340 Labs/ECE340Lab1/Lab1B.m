clear;

filename = 'baila.wav';
x3 = audioread(filename);

x3energy = sum(abs(x3).^2);

x3s = x3(1:length(x3)/2);

audiowrite('balia_half.wav', x3s, 44100);