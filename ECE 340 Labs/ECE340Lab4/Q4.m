clear
clc
% MATLAB code for spectral analysis and lowpass filtering of an image
% see section 17.6, Fig. 17.20, Fig. 17.21
%
% reading the image 'ayantika.tif'
I = imread('ayantika.tif');
imshow(I)                   % display the image
figure(2);
%fprintf('\nThe image Ayantika has been displayed')
%fprintf('\nPress any key to continue')
%pause
I = double(I);
I = I - mean(mean(I));
% 2D Bartlett window
x = bartlett(32);
for i = 1:32
    zx(i,:) = x';
	zy(:,i) = x ;
end
bartlett2D = zx .* zy;
mesh(bartlett2D) ;
%
n = 0;
% calculate power spectrum
P = zeros(256,256);
for (i = 1:16:320)
    for (j = 1:16:288)
        Isub = I(i:i+31,j:j+31).*bartlett2D;
        P = P + fftshift(fft2(Isub,256,256));
        n = n + 1;
    end
end
Pabs = (abs(P)/n).^2;
mesh([-128:127]*2/256,[-128:127]*2/256,Pabs/max(max(Pabs)));
xlabel('Horizontal Frequency'); ylabel('Vertical Frequency');
zlabel('Power Spectrum (in dB)');
print -dtiff plot.tiff

%The annoying artifact in the image is that the image seems to be
%overlayed by a checkerboard.

%The normalized range between the two axes is [-1, 1]
%The smaller peaks that represent the noise of the image are at
%the normalized locations (0.52, 0), (-0.52, 0), (0, 0.52), (0, -0.52)

