function test=ROIer(tifStack)
[xdim, ydim, timesteps]=size(tifStack);
NBIsum=zeros(xdim,ydim);
numparts=ceil(timesteps/300);
borders=linspace(1,timesteps,numparts+1);
for part=1:numparts
    NBIsum = NBIsum+nb_corr (tifStack(:,:,borders(part):borders(part+1)));
end


NBIthresh=NBIsum;
NBIthresh(NBIthresh<0.15)=0;
figure;imagesc(NBIthresh);
filter_matrix = ones(2)/(2*2);
NBIthresh=filter2(filter_matrix, NBIthresh);
NBIthresh(NBIthresh<0.15)=0;
figure; imagesc(NBIthresh);
CC=bwconncomp(NBIthresh,4);
pixelIdxList=CC.PixelIdxList;
numConns=size(pixelIdxList,2);
numROIs=1;
ROIlist={};
for Conn=1:numConns
    if size(pixelIdxList{Conn},1)>10
        ROIlist{numROIs}=pixelIdxList{Conn};
        numROIs=numROIs+1;
    end
end
numROIs=numROIs-1;
test=CC;
test.PixelIdxList=ROIlist;
test.NumObjects=numROIs;
L=labelmatrix(test);
figure, imshow(label2rgb(L,'jet','w','shuffle'));
ROIlist2={};
for ROI=1:numROIs
    if size(ROIlist{ROI},1)<100
        ROIlist2{numROIs}=ROIlist{ROI};
        numROIs=numROIs+1;
    end
end
numROIs=numROIs-1;
test=CC;
test.PixelIdxList=ROIlist2;
test.NumObjects=numROIs;
L=labelmatrix(test);
figure, imshow(label2rgb(L,'jet','w','shuffle'));