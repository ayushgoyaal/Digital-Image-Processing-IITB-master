function [corrupted,filtered,patchMask]= myPatchBasedFiltering(img,cmap,patchSize,windowSize,sigma,sigmaIntensity)
    [row,col]=size(img);
    % adding noise to image
    noise=guassainNoise(row,col,cmap);    
    out=zeros(row,col);
    corrupted=noise+img;
    
    % F(||P-Q||) is the Guassian distance fExponenet is the power of
    % e^-exponent
    mask=distance2DMask([patchSize patchSize]);
    patchMask=gaussianMask(mask,sigma);    
    
    % padding zeros outside the image. For simple masking
    pad=floor((windowSize+patchSize)/2);
    paddedCorruptedImage= [ zeros(row,pad) corrupted zeros(row,pad)];
    paddedCorruptedImage= [ zeros(pad,col+(2*pad));paddedCorruptedImage;zeros(pad,col+(2*pad))];    
    for i=1:1:row
        %fprintf('i=%d\n',i);        
        for j=1:1:col
            out(i,j)=PatchBasedFilteringVal(paddedCorruptedImage,[(i+pad) (j+pad)],windowSize,patchSize,patchMask,sigmaIntensity);
        end        
    end   
    filtered=out;
end



%function to calculate filtered value of a location
function [filteredVal]=PatchBasedFilteringVal(img,point,windowSize,patchSize,patchMask,sigmaIntensity)
    [x1,y1,x2,y2]=getWindowCoordinate(windowSize,patchSize,point);
    imgWindow=img(x1:x2,y1:y2);
    %get kth patch
    [xp1,yp1,xp2,yp2]=getPatchCoordinate(patchSize,point);
    imgPatch=img(xp1:xp2,yp1:yp2);
    weights=zeros(windowSize,windowSize);
    inc=1;
    sumOfWeight=0;
    for i=1:inc:windowSize
        for j=1:inc:windowSize
            jx=(i+floor((patchSize+1)/2));jy=(j+floor((patchSize+1)/2));            
            weights(i,j)=weightVal(imgWindow,imgPatch,[jx jy],patchSize,patchMask,sigmaIntensity);
            sumOfWeight=sumOfWeight+weights(i,j);
            iVal=imgWindow(jx,jy);
            weights(i,j)=iVal*weights(i,j);
        end
    end
    
    %{
    [rowW,colW]=size(weights);    
    pad=floor((patchSize+1)/2);
    paddedWeights= [zeros(rowW,pad) weights zeros(rowW,pad)];
    paddedWeights= [zeros(pad,colW+(2*pad));paddedWeights;zeros(pad,colW+(2*pad))];    
      
    sumOfWeights=sum(sum(weights));
    filteredMatrix=(paddedWeights./sumOfWeights).*imgWindow;    
    filteredVal=sum(sum(filteredMatrix));
     %}
    filteredVal=sum(sum(weights./sumOfWeight));
    
end


%function to calulate weight of individual patch
function weight=weightVal(img,patchk,point,patchSize,patchMask,sigmaIntensity)
    [x1,y1,x2,y2]=getPatchCoordinate(patchSize,point);
    patchj=img(x1:x2,y1:y2);   
    %fprintf('patch of the image:%d %d \n\n',point(1),point(2));
    intensityDiff=(patchj-patchk).*patchMask;
    intensityDiffSq=intensityDiff.^2;
    norm=sum(sum(intensityDiffSq));
    jValue=gaussianMask(norm,sigmaIntensity);
    weight=jValue;
end

            
    
% Generate IID guassain noise
function noise= guassainNoise(row,col,cmap)    
    %adding noise to an image
    % sd is 5% of Intensity range. 5*256=12.8
    rng(0,'twister');
    mean = 0.0;
    sigma = 0.05*cmap;
    noise = sigma.*randn(row,col) + mean;    
    %j = imnoise(uint8(img1),'gaussian',0,sigma^2/255^2);
end

function gaussianMask=gaussianMask(x,sigma)    
    exponent=x./(2*sigma^2);   
    %amplitude = 1 / (sigma * sqrt(2*pi));  
    amplitude=1;
    gaussianMask = amplitude .* exp(-exponent);
end



% Return the [x1 y1 x2 y2] coordinate of window with center as centerCoordinate
function [x1,y1,x2,y2]=getWindowCoordinate(windowSize,patchSize,centerCoordinate)
    %m=imageDim(1);n=imageDim(2);
    x=centerCoordinate(1);y=centerCoordinate(2);    
    N=floor((windowSize+patchSize)/2);
    x1=x-N;
    x2=x+N;
    y1=y-N;
    y2=y+N;

   
end

function [x1,y1,x2,y2]=getPatchCoordinate(patchSize,centerCoordinate)
    %m=imageDim(1);n=imageDim(2);
    x=centerCoordinate(1);y=centerCoordinate(2);    
    N=floor((patchSize-1)/2);   
    x1=x-N;
    x2=x+N;
    y1=y-N;
    y2=y+N;
 
end
function outImg = myShrinkImageByFactorD(img,d)
%   Shrink the image by the factor of d
    [m,n]=size(img);    
    mOut=floor(m/d);
    nOut=floor(n/d);
    outImg=zeros(mOut,nOut);
    x=1;
    y=1;    
    for i = 1:d:m
        for j = 1:d:n
            outImg(x,y)=img(i,j);
            y=y+1;
        end
        y=1;
        x=x+1;
    end
end

function mask=distance2DMask(dim)
    % Finds the Eucledian Norm ||P-Q||^2 where p=(x1,y1) and q(x2,y2)
    row=dim(1);col=dim(2);    
    centerX=ceil(row/2);centerY=ceil(col/2);
    [r,c] = ndgrid(1:dim, 1:dim);
    % Xi-x
    xDiff=r-centerX;
    % Yi-y
    yDiff=c-centerY;
    % Taking Sq (Xi-x)^2 & (Yi-y)^2
    xDiffSq=xDiff.^2;
    yDiffSq=yDiff.^2;    
    % Eucledian Norm ||P-Q||^2 i..  ( sqrt ( (Xi-x)^2 & (Yi-y)^2 ) )^2
    norm=xDiffSq+yDiffSq;
    mask=norm;
end
