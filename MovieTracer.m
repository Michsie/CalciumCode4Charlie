function MovieTracer(fmedian,ActiveNeighboursMatrix)
[ f0to5,fmedian,dN2trace,fdN2trace,ffdN2trace,ActiveRegions,...
    ActiveNeighboursMatrix,Xposis,Yposis,ActivityCentres ] = findEventsFromMovie(fmedian,ActiveNeighboursMatrix);
trace=load('CG1809134aQuick.mat');
trace=trace.FinalImage;
trace=trace(:,:,1:300);
trace=reshape(trace,512*512,300);
region=1;
meanROIActivity=zeros(1,300);
for centre=1:size(ActivityCentres(:))
    if ActivityCentres(centre)
        [X, Y]=ind2sub([512 512],ActivityCentres(centre));

        ROI=sub2ind([512 512],X-3:X+3,Y-3:Y+3);                            
% ROI=sub2ind([512 512],X-3:X+3,Y-3:Y+3);
        meanROIActivity(region,:)=mean(trace(ROI,:),1);
    end
    region=region+1;
end
meanROIActivity=meanROIActivity';
[events,singleEvents]=findCalciumEvents(meanROIActivity(:,1:50));