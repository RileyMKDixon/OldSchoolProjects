%Load image.
barbaraLarge = imread('barbaraLarge.jpg');
resizeFactor = [0.9, 0.7, 0.5];

%Display the original image.
figure(1);
imshow(barbaraLarge), colorbar; 
title('Original Image');

%Make note on how the low frequency and high frequency parts of the image
%appear, these parts should be mentioned in the lab manual.

%Antialiasing effectively blurs the image so that the high frequency portions
%of the image appear properly resized. There is information lost from
%the original image when resized, the antialiasing tries to limit the
%amount of information lost.
%Without antialiasing the image loses it's natural flow that the original
%contained.

%When the sample size is reduced the high frequency portions of the image
%are greatly affected as there is a large amount of variation between
%pixels which can lead to information loss. The computer has to choose
%which pixels to throw away and which to keepfor the new image.
%If you imagine a frequency graph
%the frequency cutoff gets smaller and smaller as the image is reduced
%further and further which will cutoff more and more of the original signal.
%In the form of this image, that means that the lines on barbara's dress
%become checker patterns.

%Create the resized images with both aliasing and nonaliasing.
barbara90NoAA = imresize(barbaraLarge, resizeFactor(1), 'nearest',...
                          'Antialiasing', 0);
barbara70NoAA = imresize(barbaraLarge, resizeFactor(2), 'nearest',...
                          'Antialiasing', 0);
barbara50NoAA = imresize(barbaraLarge, resizeFactor(3), 'nearest',...
                          'Antialiasing', 0);
barbara90AA = imresize(barbaraLarge, resizeFactor(1), 'nearest',...
                          'Antialiasing', 1);
barbara70AA = imresize(barbaraLarge, resizeFactor(2), 'nearest',...
                          'Antialiasing', 1);
barbara50AA = imresize(barbaraLarge, resizeFactor(3), 'nearest',...
                          'Antialiasing',1);

%Display the images in a subplot to comapre
figure(2);
subplot(2,3,1);
imshow(barbara90NoAA), colorbar;
title('Barbara90NoAA');

subplot(2,3,2);
imshow(barbara70NoAA), colorbar;
title('Barbara70NoAA');

subplot(2,3,3);
imshow(barbara50NoAA), colorbar;
title('Barbara50NoAA');
                      
subplot(2,3,4);
imshow(barbara90AA), colorbar;
title('Barbara90AA');

subplot(2,3,5);
imshow(barbara70AA), colorbar;
title('Barbara70AA');

subplot(2,3,6);
imshow(barbara50AA), colorbar;
title('Barbara50AA');
                      
%Save the images
imwrite(barbara90NoAA, 'barbara90NoAA.jpg', 'jpg', 'Quality', 100);
imwrite(barbara70NoAA, 'barbara70NoAA.jpg', 'jpg', 'Quality', 100);
imwrite(barbara50NoAA, 'barbara50NoAA.jpg', 'jpg', 'Quality', 100);
imwrite(barbara90AA, 'barbara90AA.jpg', 'jpg', 'Quality', 100);
imwrite(barbara70AA, 'barbara70AA.jpg', 'jpg', 'Quality', 100);
imwrite(barbara50AA, 'barbara50AA.jpg', 'jpg', 'Quality', 100);

