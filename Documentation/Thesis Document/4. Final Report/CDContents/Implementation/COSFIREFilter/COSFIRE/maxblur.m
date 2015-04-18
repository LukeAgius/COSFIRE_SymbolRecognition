function output = maxblur(inputImage,sigma)
% For a given location in the inputImage we weight the neighbourhood with a
% Gaussian coefficients and take the maximum value. This process is repeated for
% every pixel in the image.

[nr,nc] = size(inputImage);
radius = round(sigma * 3);
gauss1D = exp(-[-radius:radius].^2./(2*sigma*sigma));

% Since the gaussian function is separable we can apply it efficiently in
% the following way
output = dilateDisc(dilateDisc(inputImage,gauss1D',1,nc,1,nr),gauss1D,1,nc,1,nr);