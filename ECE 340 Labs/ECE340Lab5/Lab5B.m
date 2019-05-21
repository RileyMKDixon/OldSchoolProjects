clear;
clc;

fc = 5000;
Fs = 22050;

wc=fc/(Fs/2); 
% fc: The cut-off frequency of the fi lter 
% Fs: Sampling frequency of the audio signal 
window = hamming(513);
% Truncation window function, using Hamming window.  
% Other truncation window types may also be applicable. Please use  
% Matlab help to find more applicable truncation windows.  
filter_coeff=fir1(513-1,wc, 'high', window);  
% filter_coeff: Coefficients of the FIR filter 
figure(2);
freqz(filter_coeff,1); 
%The frequency response of the filter
%plot(response);

love_mono = audioread('love_mono22.wav');
love_mono_filtered=filter(filter_coeff,1,love_mono);  %love_mono_filtered: The filtered signal 

figure(5);
subplot(2,1,1);
[psd_mono, F1]=psd(love_mono, 512, Fs, [], 480);
plot(F1/1000, 10*log10(psd_mono)); %Plots the power spectrum
%scaling F by 1000 will represent frequency in kHz
title('Original Mono - High');
xlabel('Frequency (kHz)');
ylabel('Power Spectral Density (in dB)');

subplot(2,1,2);
[psd_filtered_mono, F2]=psd(love_mono_filtered, 512, Fs, [], 480);
plot(F2/1000, 10*log10(psd_filtered_mono)); %Plots the power spectrum
%scaling F by 1000 will represent frequency in kHz
title('Filtered Mono - High');
xlabel('Frequency (kHz)');
ylabel('Power Spectral Density (in dB)');

audiowrite('love_mono22_filtered_high.wav', love_mono_filtered, 44100);
