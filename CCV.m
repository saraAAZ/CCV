retval_image = size(0);
retval_diff= size(0);
sigma=2;
thresh= 500;

% Enter the folder Location in which your images exists
location = 'C:\Users\microsoft\Desktop\image_DBase';

%Enetr the path for an image that you wont to find the similar to it
rgb_image = imread('C:\Users\microsoft\Desktop\316.jpg');

redChannel = rgb_image(:,:,1); % Red channel
greenChannel = rgb_image(:,:,2); % Green channel
blueChannel = rgb_image(:,:,3); % Blue channel

%bluring the image
Rblur = imgaussfilt(redChannel,sigma);
Gblur = imgaussfilt(greenChannel,sigma);
Bblur = imgaussfilt(blueChannel,sigma);

Afterblur = cat(3,Rblur,Gblur,Bblur);

%Desretizetion of the Bluring Image
width = size(Afterblur,2);
height = size(Afterblur,1);
desretizedImage = zeros(height,width);
numColors=16;
numOfBins = floor(pow2(log2(numColors)/3));
img_to_desc = floor((Afterblur/(256/numOfBins)));
for i=1:height
    for j=1:width
        desretizedImage(i,j) = img_to_desc(i,j,1)*pow2(numOfBins) + img_to_desc(i,j,2)*numOfBins + ...
            floor(img_to_desc(i,j,3)*numOfBins/2);
    end
end

updatedNumC = power(numOfBins,3);

%Finding The Connected Component

min_value=min(desretizedImage(:));
max_value=max(desretizedImage(:));
connected_component=zeros(size(desretizedImage));
counter=0;

for i=min_value:max_value
    
    position_connected = desretizedImage ==i ;
    connected_c = bwlabel(position_connected);
    connected_c=connected_c+(connected_c>0)*counter;
    connected_component=connected_component+connected_c;
    counter=max(connected_component(:));
    
end

%creare table one that contain the color and the size of that color

connected = connected_component;
groupC = max(max(connected));
[n,m] = size(connected_component);
t1 = zeros([2 groupC]);

for i=1:n
    for j=1:m
        index = connected(i,j);
        t1(2,index) = t1(2,index) + 1;
        t1(1,index) = rgbImage(i,j);
    end
end

%create second table that contain alpha and beta values

levels = max(max(max(rgbImage)));

[s , r] = size(t1);
retval = zeros(2 ,levels);

for i = 1 : r
    if(t1(1,i)== 0 )
        t1(1,i)= 1;
    end
end

for i = 1 : r
    freq = t1(2,i);
    if freq == 0
        continue
    end
    if freq > thresh
        retval(1, t1(1,i)) = freq + retval(1, t1(1,i));
    else
        retval(2, t1(1,i)) = freq + retval(2, t1(1,i));
        
        
    end
end
image_retval= retval;

ds = imageDatastore(location) ;        %  Creates a datastore for all images in your folder\

image_index = 1;

while hasdata(ds)
    
    % read image from datastore
    rgbImage = read(ds) ;
    redChannel = rgbImage(:,:,1); % Red channel
    greenChannel = rgbImage(:,:,2); % Green channel
    blueChannel = rgbImage(:,:,3); % Blue channel
    
    %bluring the image
    Rblur = imgaussfilt(redChannel,sigma);
    Gblur = imgaussfilt(greenChannel,sigma);
    Bblur = imgaussfilt(blueChannel,sigma);
    
    Afterblur = cat(3,Rblur,Gblur,Bblur);
    
    %Desretizetion of the Bluring Image
    
    width = size(Afterblur,2);
    height = size(Afterblur,1);
    desretizedImage = zeros(height,width);
    numColors=16;
    numOfBins = floor(pow2(log2(numColors)/3));
    img_to_desc = floor((Afterblur/(256/numOfBins)));
    
    for i=1:height
        for j=1:width
            desretizedImage(i,j) = img_to_desc(i,j,1)*pow2(numOfBins) + img_to_desc(i,j,2)*numOfBins + ...
                floor(img_to_desc(i,j,3)*numOfBins/2);
        end
    end
    
    updatedNumC = power(numOfBins,3);
    
    %Finding The Connected Component
    
    min_value=min(desretizedImage(:));
    max_value=max(desretizedImage(:));
    connected_component=zeros(size(desretizedImage));
    counter=0;
    
    for i=min_value:max_value
        
        position_connected = desretizedImage ==i ;
        connected_c = bwlabel(position_connected);
        connected_c=connected_c+(connected_c>0)*counter;
        connected_component=connected_component+connected_c;
        counter=max(connected_component(:));
        
    end
    
    %creare table one that contain the color and the size of that color
    
    connected = connected_component;
    groupC = max(max(connected));
    [n,m] = size(connected_component);
    t1 = zeros([2 groupC]);
    
    for i=1:n
        for j=1:m
            index = connected(i,j);
            t1(2,index) = t1(2,index) + 1;
            t1(1,index) = Afterblur(i,j);
        end
    end
    
    
    levels = max(max(max(rgbImage)));
    
    [s , r] = size(t1);
    retval = zeros(2 ,levels);
    
    for i = 1 : r
        if(t1(1,i)== 0 )
            t1(1,i)= 1;
        end
    end
    
    for i = 1 : r
        freq = t1(2,i);
        if freq == 0
            continue
        end
        if (freq > thresh)
            retval(1, t1(1,i)) = freq + retval(1, t1(1,i));
        else
            retval(2, t1(1,i)) = freq + retval(2, t1(1,i));
            
            
        end
    end
    if (size(image_retval) == size(retval ))
    distance = sum(sum(abs(image_retval-retval)));
    retval_diff(image_index) = distance;
    else
        retval_diff(image_index) = 1000000000;
    end
    
    
    image_index=image_index + 1;
    
end


%Finding the 3 minimum values in the Arra y

retreval = abs(retval_diff);
max_Index = zeros(1,3);

for j=1:3
    [M,I] = min(retval_diff);
    retval_diff(1,I)=1000000;
    max_Index(1,j) = I;
end

img1=readimage(ds,max_Index(1,1));
img2=readimage(ds,max_Index(1,2));
img3=readimage(ds,max_Index(1,3));


subplot(1,4,1), imshow(rgb_image)
subplot(1,4,2), imshow(img1)
subplot(1,4,3), imshow(img2)
subplot(1,4,4), imshow(img3)

