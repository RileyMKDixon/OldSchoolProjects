% EE338 Lab 2
% test3.m

clear
clc
close all

I=imread('barbaraLarge.jpg');
% Low pass filtering before downsampling
filt=fspecial('average',[3 3]);                 % creates a 3x3 low pass filter kernel
filt_img=imfilter(I,filt,'conv');               % applies the lpf by convolving the image with the filter kernel

B_LPF=imresize(filt_img, 0.7 , 'nearest');
B=imresize(I, 0.7, 'nearest');

figure,  imshow(I); title('Original Barbara Image');
figure,  imshow(B); title('Barbara Image resized by 70% of original size');
figure,  imshow(B_LPF); title('Low pass filter applied before Resizing to 70% of original size');

