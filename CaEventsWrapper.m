function CaEventsWrapper(meanROIActivity)
[events,singleEvents,CsingleEvents,Ntrace,OnsetRemoved,StdRemoved,EventEnds,minDurRemovedEvents,stdThreshMatrix]=findCalciumEvents(meanROIActivity);
TifStack=load('CG1809134aQuick.mat');
TifStack=TifStack.FinalImage;
OverviewImage=load('fmedianAndf0.mat');
OverviewImage=OverviewImage.fmedian;
analyseCalciumSignalsGUI(Ntrace,OverviewImage,TifStack,CsingleEvents,events,StdRemoved,OnsetRemoved,meanROIActivity,EventEnds,minDurRemovedEvents,stdThreshMatrix);