function CaEventsWrapper(meanROIActivity)
[events,singleEvents,CsingleEvents,Ntrace]=findCalciumEvents(meanROIActivity);
TifStack=load('CG1809134aQuick.mat');
TifStack=TifStack.FinalImage;
OverviewImage=load('fmedianAndf0.mat');
OverviewImage=OverviewImage.fmedian;
analyseCalciumSignalsGUI(Ntrace,OverviewImage,TifStack,CsingleEvents);