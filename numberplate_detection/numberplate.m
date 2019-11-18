%  LICENSE PLATE DETECTION

% read image
img = imread("1.jpg");

% convert the truecolor image RGB to the grayscale intensity image
grayimg = rgb2gray(img);

% computes a global threshold T from grayscale image
threshold = graythresh(grayimg);

%%%%%%%%%%%%%% STEP 1 : Vertical edge detection %%%%%%%%%%%%%% 

% Do a Sobel edge detection
edgeDetectedImage = edge(grayimg, 'Sobel');

% display image
% imshow(edgeDetectedImage);

% get size of grayscale img
[imageHeight, imageWidth] = size(grayimg);

%%%%%%%%%%%%%%% STEP 2 : Perform morphological operations %%%%%%%%%%%%%% 

% create a structuring element of shape rectangle with 1 row and 50 columns
structuringElement = strel('rectangle', [1, 50]);

% Perform morphological closing of the edge detection 
closedImage = imclose(edgeDetectedImage, structuringElement);

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

for i = 1 : imageHeight
    for j = 1 : imageWidth
        subimg(i,j) = openedImage1(i,j) - openedImage2(i,j);
    end
end

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

% Find connected objects - 8 way connectivity
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
