% Image Compression Using Discrete Cosine Transform(DCT)
% Dr.K.Somasundaram - ka.somasundaram@gmail.com
% Dr.T.Kalaiselvi   - kalaivpd@gmail.com
%------------------------------------------------------
function [] = ImCompDCT(inputFilePath)
% Read the image
disp('Image compression by using DCT and blockproc function');
tic;
im = imread(inputFilePath);
% Convert RGB to grayscale
% inim - input image
inim = double(rgb2gray(im));
disp('The given image is RGB. It is converted to grayscale');
[r,c] = size(inim);
dim = strcat('image size',int2str(r),'X',int2str(c),' pixels');
disp(dim);
inim1 = uint8(inim);
%--------------------------
%Compression
%--------------------------
figure(1)
imshow(inim1);
title 'Original Image';
% Divide the image into 8X8 block and apply dct on each block
% and downshift the intensity levels by 256
blksize = 8;
dctcoef = blockproc(inim,[blksize, blksize],@(block_struct)dct2(block_struct.data));
% Design a filter to remove the coefiicients in a zig zag manner
filt28 = [...
    1 1 1 1 1 1 1 0;
    1 1 1 1 1 1 0 0;
    1 1 1 1 1 0 0 0;
    1 1 1 1 0 0 0 0;
    1 1 1 0 0 0 0 0;
    1 1 0 0 0 0 0 0;
    1 0 0 0 0 0 0 0;
    0 0 0 0 0 0 0 0];
% Cut the coefficients using the filter filt
filt10 = [...
    1 1 1 1 0 0 0 0;
    1 1 1 0 0 0 0 0;
    1 1 0 0 0 0 0 0;
    1 0 0 0 0 0 0 0;
    0 0 0 0 0 0 0 0;
    0 0 0 0 0 0 0 0;
    0 0 0 0 0 0 0 0;
    0 0 0 0 0 0 0 0];
filt6 = [...
    1 1 1 0 0 0 0 0;
    1 1 0 0 0 0 0 0;
    1 0 0 0 0 0 0 0;
    0 0 0 0 0 0 0 0;
    0 0 0 0 0 0 0 0;
    0 0 0 0 0 0 0 0;
    0 0 0 0 0 0 0 0;
    0 0 0 0 0 0 0 0];
filt = filt10;
% Remove as many dct coefficients as needed, by compression required
% filt10 retains only 10 co-efficients out of 64
cuttcoef = blockproc(dctcoef,[blksize, blksize],@(block_struct)block_struct.data.*filt);
%-----------------------------------------------
% Decompression
%-------------------------------------------------
decompim = blockproc(cuttcoef,[blksize, blksize],@(block_struct)idct2(block_struct.data));
figure(2);
imshow(decompim,[]);
title 'Reconstructed Image';
%Compute PSNR
% Find the error in pixel values
DIF = imsubtract(inim,decompim);
mse = mean(mean(DIF.*DIF));
rmse = sqrt(mse);
psnr = 20 * log(255/rmse);
disp('PSNR');
disp(psnr);
toc