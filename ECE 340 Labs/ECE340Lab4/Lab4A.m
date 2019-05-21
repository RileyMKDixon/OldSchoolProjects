clear;
clc;

fileName = 'love_mono22.wav';
mono = audioread(fileName);
monoInfo = audioinfo(fileName);

%audioinfo partitioned into what we care about.
fileSize = monoInfo.TotalSamples;
samplingRate = monoInfo.SampleRate;
duration = monoInfo.Duration;
numOfBits = 8 * fileSize;
bitRate = fileSize/samplingRate;

fourierTransform = fft(mono);
%The positive frequencies are the first half.
positiveFT = fourierTransform(1:fileSize/2);
absScaledPositiveFT = abs(positiveFT./sqrt(fileSize/2));
frequency = linspace(1, samplingRate/2, length(positiveFT))/1000;

%Plot the magnitude spectrum
figure(1);
plot(frequency, 20*log10(absScaledPositiveFT));
title('Magnitude Spectrum');
xlabel('Frequency (kHz)');
ylabel('Magnitude of the FT of ''mono''');

%The magnitude spectrum plot curves downwards initially
%and has an upwards spike at 3kHz and a downwards spike at 2kHz
%and afterwards tapers at about -35dB

[Px, F]=psd(mono, 512, samplingRate, [], 480);
figure(2);
plot(F/1000, 10.*log10(Px)); 
%Plots the power spectrum
%scaling F by 1000 will represent frequency in kHz
title('Power Spectrum');
xlabel('Frequency (kHz)');
ylabel('Power Spectral Density (in dB)');

%The audio file has the most energy from 0kHz to 2KHz, in addition
%there is a burst of energy around the 3kHz mark.



