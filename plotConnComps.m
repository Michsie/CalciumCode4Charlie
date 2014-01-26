function [bigComps,tracedImage]=plotConnComps(fmedian)
% good setting with filter ones(3) and >1000 gives only 4 big components
% but they can then be subdivided
BW=edge(fmedian,'log',3);
fBW=filter2(ones(3),BW);
CC=bwconncomp(fBW,4);
conncomps=CC.PixelIdxList;
numComps=size(conncomps,2);
bigComps={};
numBigComps=0;
figure;imagesc(fmedian);
tracedImage=zeros(512*512,1);
for comp=1:numComps
    if numel(conncomps{comp})>1000
        numBigComps=numBigComps+1;
        bigComps{numBigComps}=conncomps{comp};
        [X,Y]=ind2sub([512,512],bigComps{numBigComps});
        tracedImage(conncomps{comp})=1;
        
        hold on; scatter(Y,X,'.k'); 
    end
end
tracedImage=reshape(tracedImage,512,512);
figure;imagesc(tracedImage);


    

        