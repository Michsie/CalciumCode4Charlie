function [Ntrace,NtraceSummary]=plotAllTraces(meanROIActivity)
[timesteps, numspines]=size(meanROIActivity);
f0to5=mean(meanROIActivity(1:5,:));
f0to5=repmat(f0to5,timesteps,1);
fmedian=median(meanROIActivity,1);
fmedian=repmat(fmedian,timesteps,1);
trace=meanROIActivity;
% Ntrace=(trace-f0to5)./f0to5;
Ntrace=(trace-fmedian)./fmedian;
[time, spine]=find(Ntrace>500);
badSpines=unique(spine);
for badspine=1:numel(badSpines)
    Ntrace(:,badSpines(badspine))=zeros(timesteps,1);
end
for spine=1:numspines
NtraceSummary(:,spine)=Ntrace(:,spine)+spine-1;
end
figure;plot(NtraceSummary);