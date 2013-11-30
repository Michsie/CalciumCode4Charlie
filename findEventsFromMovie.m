function [ f0to5,fmedian,dN2trace,fdN2trace,ffdN2trace,ActiveRegions,ActiveNeighboursMatrix,Xposis,Yposis,ActivityCentres ] = findEventsFromMovie(fmedian,ActiveNeighboursMatrix)

%UNTITLED3 Summary of this function goes here

% without  meanROI Activity, compute Nvideo similiar to Ntrace just use
% tiffstack for that. then get dNvideo and do some smoothing 2pixels
% radius? so 25 pixel filter again?. binarise with 15% ? Maybe choose 
% similiar to Kleindienst_Lohmann paper 10 connected pixels to define an
% event.Maybe use ddNvideo as well to have not only a spatial size but also
% a timelength as criteria? Do some correlation analysis. to find extend
% spatiotemporally of events.
uint8or16='uint16';
% tifStack=openTifStack(uint8or16);
trace=load('CG1809134aQuick.mat');
trace=trace.FinalImage;
trace=trace(:,:,1:300);
% StackSlider(tifStack,uint8or16);
trace=double(trace);
[xdim, ydim, timesteps]=size(trace);
f0to5=mean(trace(:,:,1:5),3);

if nargin==0
    fmedian=zeros(xdim,ydim);
    for X=1:xdim
        
        fmedian(X,:)=median(trace(X,:,:),3);
        if mod(X,100)==50
            X
        end
    end

%     save('fmedian','fmedian');
end
% Ntrace=trace;
N2trace=trace;
for timestep=1:timesteps
%     Ntrace(:,:,timestep)=(trace(:,:,timestep)-f0to5)./f0to5;
    N2trace(:,:,timestep)=(trace(:,:,timestep)-fmedian)./fmedian;
    if mod(timestep,100)==50
        timestep
    end
end
% f0to5matrix=repmat(f0to5,1,1,timesteps);
% save('f0to5','f0to5'); %-v7.3 switch

% Ntrace=(trace-f0to5)./f0to5;
clear('trace');
% implay(Ntrace);
% implay(N2trace);
dN2trace=diff(N2trace,1,3);
clear('N2trace');
% implay(dN2trace);
                                                                            % filter_matrix = ones(5)/(5*5);
                                                                            % fdN2trace=zeros(xdim,ydim,timesteps-1);
                                                                            % for timestep=1:timesteps
                                                                            %     fdN2trace(:,:,timestep) = filter2(filter_matrix, dN2trace(:,:,timestep));
                                                                            % end
                                                                            % 
                                                                            % implay(fdN2trace);
                                                                            % clear('dN2trace');
                                                                            
%the following works really well to only pick up strong calcium events!
% would be great if i could somehow colour these pixels and show them in
% initial video!!!
se = strel('disk',1);        
fdN2trace = imerode(dN2trace,se);
% clear('dN2trace');
% implay(fdN2trace);
binarisedTrace=fdN2trace>0;
% implay(binarisedTrace);
if nargin<2
    ActiveNeighboursMatrix=zeros(xdim,ydim,timesteps-1);
    for timestep=1:timesteps-1
        for xstep=3:xdim-2
            for ystep=3:ydim-2
                if binarisedTrace(xstep,ystep,timestep)
                     ActiveNeighbours=sum(sum(sum(binarisedTrace(xstep-2:xstep+2,ystep-2:ystep+2,timestep))));
                        ActiveNeighboursMatrix(xstep,ystep,timestep)=ActiveNeighbours;

                end
            end
        end
        if mod(timestep,30)==15
            timestep
        end
    end
end
fbinarisedTrace=zeros(xdim,ydim,timesteps-1);

ActiveNeigboursThreshold=20*std(ActiveNeighboursMatrix(:))+mean(ActiveNeighboursMatrix(:));
fbinarisedTrace(ActiveNeighboursMatrix>ActiveNeigboursThreshold)=1;
% for timestep=1:timesteps-1
%     for xstep=3:xdim-2
%         for ystep=3:ydim-2
%             if binarisedTrace(xstep,ystep,timestep)
%                 if ActiveNeighboursMatrix(xstep,ystep,timestep)>ActiveNeigboursThreshold
%                     fbinarisedTrace(xstep,ystep,timestep)=1;
%                 end
%             end
%         end
%     end
%     if mod(timestep,30)==15
%         timestep
%     end
% end
% implay(fbinarisedTrace);
ffdN2trace=fbinarisedTrace.*fdN2trace;
% implay(ffdN2trace);
ActiveRegions=sum(ffdN2trace,3);
figure;imagesc(ActiveRegions);
% [Xposis Yposis]=find(ActiveRegions);
CC=bwconncomp(ActiveRegions>0);                                             %  however there is problem with followin important to exclude borders (5:end-5,5:end-5)
pixelIdxList=CC.PixelIdxList;
NumActiveRegions=size(pixelIdxList,2);
dN2average=sum(dN2trace,3);
dN2average=dN2average(:);
ActivityCentres=zeros(NumActiveRegions,1);
for region=1:NumActiveRegions
    
    pixels=pixelIdxList{region};
    [X Y]=ind2sub([512 512],pixels);
    % find geometric centres
    Xposi=ceil(median(X));
    Yposi=ceil(median(Y(X==Xposi(1))));
    Xposis(region)=Xposi(1);
    Yposis(region)=Yposi;
    
    % find activity centres
    if Xposis(region)>5 && Yposis(region)>5 && Xposis(region)<(512-5) && Yposis(region)<(512-5)
        ActivityCentre=find(dN2average==max(dN2average(pixels)));
        ActivityCentres(region)=ceil(mean(ActivityCentre(:)));                        %activity centres close to geometric centres
    end 
end
figure; imagesc(ActiveRegions);
hold on; scatter(Yposis,Xposis,'ok'); 

            




