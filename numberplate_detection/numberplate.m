img = imread("1.jpg");
procimg = rgb2gray(img);

thresh = graythresh(procimg);

edgeDetectedImage = edge(procimg, 'Sobel');

imshow(edgeDetectedImage);

[height, width] = size(procimg);

SE = strel('rectangle', [1,50]);
closeProcImg = imclose(edgeDetectedImage, SE);

SE = strel('rectangle', [30,1]);
openProcImg1 = imopen(closeProcImg, SE);

SE = strel('rectangle', [100,1]);
openProcImg2 = imopen(openProcImg1, SE);

subimg = zeros(height, width);
for i = 1 : height
    for j = 1 : width
        subimg(i,j) = openProcImg1(i,j) - openProcImg2(i,j);
    end
end

SE = strel(1,100);
subimg = imopen(subimg,SE);

for i = 1 : height
    for j = 1 : width
        procimg(i,j) = procimg(i,j) * subimg(i,j);
    end
end

cc = bwconncomp(procimg, 8);
stats = regionprops(cc, 'Perimeter');
idx = find([stats.Perimeter] > 800);
finalimg = double(ismember(labelmatrix(cc), idx));

for i = 1 : height
    for j = 1 : width
        procimg(i,j) = procimg(i,j) * finalimg(i,j);
    end
end

imshow(procimg);
