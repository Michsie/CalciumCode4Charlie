function data=findCalciumEvents(meanROIActivity,stdMultiplier,slopeThresh,OnsetDist,...
    minDur,BaselineDur,PeakSearchDur)
% data=[events,CsingleEvents,Ntrace,onsetTimingRemovedEvents,stdRemovedEvents,...
%     minDurRemovedEvents,EventEnds,stdThreshMatrix,tableFigureHandle,tableHandle]
% detects events from traces of mean ROI intensities over time
% by thresholding the first derivative of the signal as a long lasting
% changing time above a moderate change threshold or a short lasting
% changing time above a higher change threshold
% Input format as [timesteps,ROIsignals];
[Ntrace,NtraceSummary]=plotAllTraces(meanROIActivity);                      % normalise traces a deltaF/F0 and plot
[timesteps, numspines]=size(Ntrace);                                        % get dimensions
%------------------------------------------------------------------

%-----------------------------------------------------------------

%diff approach
if nargin==1
    OnsetDist=5;
    stdMultiplier=2;
    slopeThresh=0.05;
    minDur=7;
    BaselineDur=100;
    PeakSearchDur=15;                                                       % how long to search for peak after event onset in frames
end
                                                       
dNtrace=diff(Ntrace);                                                       % take the difference between each timepoint and the following
dElevatingTimes=zeros(timesteps, numspines);                                % generate a matrix for storing the differentially elevated timepoints
HighdElevatingTimes=zeros(timesteps, numspines);                            % generate another matrix for a higher threshold
[times, spines]=find(dNtrace>slopeThresh);                                       % find the differentially elevated timepoints above moderate threhold
[Hightimes, Highspines]=find(dNtrace>slopeThresh*2);                                % find the ones above a higher threshold
for spine=1:numspines                                                       
    dElevatingTimes(times(spines==spine),spine)=1;                          % assign a 1 to all timepoints above threhold
    HighdElevatingTimes(Hightimes(Highspines==spine),spine)=1;
end
events=zeros(timesteps, numspines);                                         % generate a matrix for events
ddElevatingTimes=diff(dElevatingTimes);                                     % compute the second derivative showing a change int the state of being differentially elevated above a moderate threshold
for spine=1:numspines                                                       % loop through spines and find the onset of events
    events(((dElevatingTimes(1:end-1,spine)==1 & ...                        % find events that are ( differentially elevated above a moderate threshold and
        ddElevatingTimes(:,spine)==0))| ...
        HighdElevatingTimes(1:end-1,spine)==1,spine)=1; %:P                 % differentially elevated above a higher threshold
end
devents=diff(events);                                                       % in case of a longer lasting rising phase, select the first detected event timepoint as the onset of the event
events(2:end,:)=devents;                                                    % overwrite the old event matrix with this corrected data
events(end-PeakSearchDur:end,:)=0;                                          % too late onsets are ignored because they are too close to end of recording



onsetTimingRemovedEvents=zeros(timesteps,numspines);
for spine=1:numspines
    spineEvents=find(events(:,spine));
    for event=1:numel(spineEvents)
        if event<numel(spineEvents) && events(spineEvents(event),spine)==1 ...
            && spineEvents(event+1)-spineEvents(event)<OnsetDist
            events(spineEvents(event+1),spine)=0;  
            onsetTimingRemovedEvents(spineEvents(event+1),spine)=1;
        end
    end
end
stdThreshMatrix={};
stdRemovedEvents=zeros(timesteps,numspines);
EventBaselineMatrix=zeros(timesteps,numspines);
for spine=1:numspines
    spineEvents=find(events(:,spine));
    for event=1:numel(spineEvents)
        currPeakSearchDur=PeakSearchDur;
        currBaselinePre=BaselineDur/2;
        currBaselinePost=currBaselinePre;
            if event<numel(spineEvents)
                if (spineEvents(event+1)-spineEvents(event))<PeakSearchDur
                    currPeakSearchDur=spineEvents(event+1)-spineEvents(event);
                end
            end
            if (size(events,1)-spineEvents(event))<currPeakSearchDur
                currPeakSearchDur=size(events,1)-spineEvents(event);
            end
            if (size(events,1)-spineEvents(event))<currBaselinePost
                currBaselinePost=size(events,1)-spineEvents(event);
            end
            %  doing independent peak and std/mean search durations, but this might work too
            if (spineEvents(event)-1)<currBaselinePre
                currBaselinePre=spineEvents(event)-1;
            end    
            peakAmp=max(Ntrace(spineEvents(event):spineEvents(event)+currPeakSearchDur,spine));
            if spineEvents(event)-currBaselinePre<1 || spineEvents(event)+currPeakSearchDur<1
                'help'
            end
            baselineMean=mean(Ntrace(spineEvents(event)-currBaselinePre:spineEvents(event)+currBaselinePost,spine));
            peakAmpThresh=stdMultiplier*std(Ntrace(spineEvents(event)-currBaselinePre:spineEvents(event)+currBaselinePost,spine))...
                +baselineMean;
            stdThreshMatrix{spine,event}=[spineEvents(event)-currBaselinePre,spineEvents(event)+currBaselinePost,peakAmpThresh];
            EventBaselineMatrix(spineEvents(event),spine)=baselineMean;
%             plot(Ntrace(:,spine));hold on;
%             plot(spineEvents(event),Ntrace(spineEvents(event),spine),'ro');
%             plot((spineEvents(event)-currPeakSearchBackDur):(spineEvents(event)+currPeakSearchDur),...
%                 peakAmpThresh*ones(currPeakSearchBackDur+currPeakSearchDur+1,1),'-r');
%             plot(1:1501,mean(Ntrace(spineEvents(event)-currPeakSearchBackDur:spineEvents(event)+currPeakSearchDur,spine)),'-r');

            if peakAmp<peakAmpThresh
                events(spineEvents(event),spine)=0;
                stdRemovedEvents(spineEvents(event),spine)=1;
%                 'removed'
            end
        
    end
end
for spine=1:numspines                                                       % produce summaries for plotting by spacing them by one unit
    eventsSummary(:,spine)=events(:,spine)+spine-1;
end    

%-------------------------------------------------------------------
% find single events/ remove events that are due to spread of signal
                                                       
EventEnds=zeros(timesteps, numspines); 
EventCorrespondingEnd=zeros(timesteps, numspines); 
for timestep=1:timesteps
    for spine=1:numspines
        if events(timestep,spine)==1                                        % stop of rising phase is encoded in events by -1
            endpoint=timestep;
            baselineValue=EventBaselineMatrix(timestep,spine);
            while endpoint<timesteps-2 && ... 
                    (Ntrace(endpoint,spine)>=baselineValue || ...
                    dElevatingTimes(endpoint,spine)==1)
                endpoint=endpoint+1;                                        % 
            end
            
            EventEnds(endpoint,spine)=1;
            EventCorrespondingEnd(timestep,spine)=endpoint;
            
        end
    end
end

minDurRemovedEvents=zeros(timesteps,numspines);
for spine=1:numspines
    spineEvents=find(events(:,spine));
    for event=1:numel(spineEvents)
        if EventCorrespondingEnd(spineEvents(event),spine)-spineEvents(event)<minDur
            events(spineEvents(event),spine)=0;  
            minDurRemovedEvents(spineEvents(event),spine)=1;
        end
    end
end

% preparing and plotting
for spine=1:numspines
    EventEndSummary(:,spine)=EventEnds(:,spine)+spine-1;             % produce summary for single events
end   
figure;plot(NtraceSummary); hold on;                                        % plot normalised trace
for spine=1:numspines
    plot(find(EventEndSummary(:,spine)>spine-1),...                     % overlay single events
        NtraceSummary(EventEndSummary(:,spine)>spine-1,spine), 'ro'); 
end
for spine=1:numspines                                                       % loop through all ROIs
    plot(find(eventsSummary(:,spine)>spine-1),...                           % get the X values of the event onsets for the current ROI in the event Summary - therefore '> spine-1' and not '>1' to counteract the 1 unit spacing in the summary matrix (could probably use normal event matrix here for less confusion)
        NtraceSummary(eventsSummary(:,spine)>spine-1,spine), 'ko');         % then find the corresponding Y values in the original signal trace of the current ROI and label them with a black circle
end
% get rid of correlated duplicates

% NumEvents=sum(events(:)==1);
CsingleEvents=zeros(timesteps, numspines);
for timestep=1:timesteps
    for spine=1:numspines
        if events(timestep,spine)==1
            corrRmatrix=zeros(numspines,1);
            corrPmatrix=zeros(numspines,1);
            endpoint=EventCorrespondingEnd(timestep,spine);
            if endpoint==0
                'error, no corresponding endpoint'
            end
            SpineEventTrace=Ntrace(timestep:endpoint,spine);
            Biggest=1;
            for otherspine=1:numspines
                if otherspine~=spine
                    OtherSpineEventTrace=Ntrace(timestep:endpoint,otherspine);
                    [R,P]=corrcoef(SpineEventTrace,OtherSpineEventTrace);   % problem here with lower thresh?
                    if numel(R)==1
                        'why'
                    end
                    corrRmatrix(otherspine)=R(1,2);
                    
                    corrPmatrix(otherspine)=P(1,2);
                    
                    if P(1,2)<0.001 && spine~=otherspine
                        if sum(SpineEventTrace-OtherSpineEventTrace)<0                                     % check whether the sum of normalised signal is smaller 
                            Biggest=0;
                        end
                    end
                        

                end
            end
            if Biggest                                                      % if biggest is still one, i.e. if the differential signal is the strongest for the putative event trace
            CsingleEvents(timestep,spine)=1;                                % then keep it
            end
            if sum(corrPmatrix<0.00)>1
%                 figure;plot(corrRmatrix);
                figure;plot(corrPmatrix);
            end
        end
    end
end

for spine=1:numspines                                                       % summary matrix
    CsingleEventsSummary(:,spine)=CsingleEvents(:,spine)+spine-1;
end   
PureEvents=figure;plot(NtraceSummary); hold on;                                        % plot
for spine=1:numspines
    plot(find(CsingleEventsSummary(:,spine)>spine-1),...
        NtraceSummary(CsingleEventsSummary(:,spine)>spine-1,spine), 'ko'); 
end
set(PureEvents, 'HandleVisibility', 'off');
% end of correlated analysis
  
[tableFigureHandle,tableHandle]=createDatatable(CsingleEvents,EventCorrespondingEnd);

data.events=events;
data.CsingleEvents=CsingleEvents;
data.Ntrace=Ntrace;
data.onsetTimingRemovedEvents=onsetTimingRemovedEvents;
data.stdRemovedEvents=stdRemovedEvents;
data.minDurRemovedEvents=minDurRemovedEvents;
data.EventEnds=EventEnds;
data.stdThreshMatrix=stdThreshMatrix;
data.tableFigureHandle=tableFigureHandle;
data.tableHandle=tableHandle;




