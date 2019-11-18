%  LICENSE PLATE DETECTION

% read image
img = imread("1.jpg");

%%%%%%%%%%%%%% STEP 1 : Vertical edge detection %%%%%%%%%%%%%% 

% convert the truecolor image RGB to the grayscale intensity image
grayimg = rgb2gray(img);

% computes a global threshold T from grayscale image
threshold = graythresh(grayimg);

% Do a Sobel edge detection
edgeDetectedImage = edge(grayimg, 'Sobel');

% display image
% imshow(edgeDetectedImage);

%%%%%%%%%%%%%%% STEP 2 : Perform morphological operations %%%%%%%%%%%%%% 

% Goal - To ensure that the license plate is not cropped

% get size of grayscale img
[imageHeight, imageWidth] = size(grayimg);

% create a structuring element of shape rectangle with 1 row and 50 columns
structuringElement = strel('rectangle', [1, 50]);

% Perform morphological closing of the edge detection 
closedImage = imclose(edgeDetectedImage, structuringElement);

% Goal - some processing needs to be done to eliminate the regions that do not contain the license plate 

% regions with height greater than the maximum character height are eliminated by performing sequence of two opening operations.

% create a structuring element of shape rectangle with 30 rows and 1 columns
structuringElement = strel('rectangle', [30, 1]);

% Perform morphological opening
openedImage1 = imopen(closedImage, structuringElement);

% create a structuring element of shape rectangle with 100 rows and 1 columns
structuringElement = strel('rectangle', [100, 1]);

% Perform morphological opening
openedImage2 = imopen(openedImage1, structuringElement);

% create a matrix with all zeroes
subimg = zeros(imageHeight, imageWidth);

% This results in the elimination of regions with height greater than the maximum license plate height.

for i = 1 : imageHeight
    for j = 1 : imageWidth
        subimg(i,j) = openedImage1(i,j) - openedImage2(i,j);
    end
end

% Finally, an image opening operation with horizonital SE (SE width is less than minimum license plate width) 
% eliminiates the noise blobs whose width is less than minimum width of license plate. 

% create a structuring element
structuringElement = strel(1, 100);

% Perform morphological opening
subimg = imopen(subimg,structuringElement);

for i = 1 : imageHeight
    for j = 1 : imageWidth
        grayimg(i,j) = grayimg(i,j) * subimg(i,j);
    end
end

%%%%%%%%%%%%%%%% STEP 3 : Find connected component %%%%%%%%%%%%%%%

% Find connected objects - eight-connected-component extraction algorithm
connectedComponents = bwconncomp(grayimg, 8);

% Compute properties of image regions.
properties = regionprops(connectedComponents, 'Perimeter');

% Return a vector of indices where property parameter is >800
idx = find([properties.Perimeter] > 800);

% Create labelled matrix from bwconncomp structure, then
% returns a logical matrix with the same shape as original matrix
finalImage = double(ismember(labelmatrix(connectedComponents), idx));

for i = 1 : imageHeight
    for j = 1 : imageWidth
        grayimg(i,j) = grayimg(i,j) * finalImage(i,j);
    end
end

% display image
imshow(grayimg);
