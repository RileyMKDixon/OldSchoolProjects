clear;

filename = 'lena.jpg';
lena = imread(filename);
[lenaRows, lenaColumns] = size(lena);

pixels = lenaRows * lenaColumns;

lena_bright = lena + 30;
imwrite(lena_bright, 'lena_bright.jpg', 'jpg', 'Quality', 100);

%The lena_bright image appears to be more white.
%In better words, the greyscale has been shifted towards white by 30
%points.