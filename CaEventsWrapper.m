function CaEventsWrapper(meanROIActivity)
% [events,CsingleEvents,Ntrace,OnsetRemoved,StdRemoved,...
%     minDurRemovedEvents,EventEnds,stdThreshMatrix,tableFigureHandle,tableHandle]
data=findCalciumEvents(meanROIActivity);
TifStack=load('CG1809134aQuick.mat');
TifStack=TifStack.FinalImage;
OverviewImage=load('fmedianAndf0.mat');
OverviewImage=OverviewImage.fmedian;
analyseCalciumSignalsGUI(data,OverviewImage,TifStack,meanROIActivity);

% % this opens ROIs from ROIfolder of unzipped imageJ ROI zip; number
% % corresponds to excel sheet polygon number/ number displayed in
% % image J ROI manager and file name BUT not number displayed in imageJ
% % image
% roi=ReadImageJROI('CG1809134_Polygon12-0.roi');
% load('fmedianAndf0.mat')
% figure;imagesc(fmedian);
% hold on;rectangle('Position',[roi.vnRectBounds(2),roi.vnRectBounds(1),roi.vnRectBounds(4)-roi.vnRectBounds(2),roi.vnRectBounds(3)-roi.vnRectBounds(1)])