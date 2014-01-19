function [events,singleEvents,CsingleEvents,Ntrace,onsetTimingRemovedEvents,stdRemovedEvents,minDurRemovedEvents,EventEnds,stdThreshMatrix]=findCalciumEvents(meanROIActivity,stdMultiplier,slopeThresh,OnsetDist)
% detects events from traces of mean ROI intensities over time
% by thresholding the first derivative of the signal as a long lasting
% changing time above a moderate change threshold or a short lasting
% changing time above a higher change threshold
% Input format as [timesteps,ROIsignals];
[Ntrace,NtraceSummary]=plotAllTraces(meanROIActivity);                      % normalise traces a deltaF/F0 and plot
[timesteps, numspines]=size(Ntrace);                                        % get dimensions
%------------------------------------------------------------------
% std-threshold based approach
% not that applicable therefore not used
threshold=mean(Ntrace)+2*std(Ntrace);                                       % compute a threshold 2 std above the mean
for spine=1:numspines                                                       % loop through all ROIs and find timepoints above threshold
    thresholdSummary(spine)=threshold(spine)+spine-1;                       % create a summary spaced by 1 unit for plotting all traces
    ElevatedTimes{spine}=find(Ntrace(:,spine)>threshold(spine));            % find elevated timepoints
end
thresholdSummary=repmat(thresholdSummary,timesteps,1);                      % extend the threshold summary in the time dimensions
% figure;plot(NtraceSummary); hold on; plot(thresholdSummary,'--');           % plot the normalised trace and the thresholds
% for spine=1:numspines                                                       % loop through all ROIs and plot the elevated timepoints
%     plot(ElevatedTimes{spine},...
%         NtraceSummary(ElevatedTimes{spine},spine), 'ko');
% end
%-----------------------------------------------------------------
%         (dElevatingTimes(1:end-1,spine)==1 & ...
%         peakTimes==1)|...
%diff approach
if nargin==1
    OnsetDist=5;
    stdMultiplier=2;
    slopeThresh=0.05;
    minDur=7;
end
minDur=7; %remove this!!!!!!!!!!!!!!!!
PeakSearchDur=15;                                                           % how long to search for peak after event onset in frames

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
for spine=1:numspines
    spineEvents=find(events(:,spine));
    for event=1:numel(spineEvents)
        currPeakSearchDur=PeakSearchDur;
        
            if event<numel(spineEvents)
                if (spineEvents(event+1)-spineEvents(event))<PeakSearchDur
                    currPeakSearchDur=spineEvents(event+1)-spineEvents(event);
                end
            end
            if (size(events,1)-spineEvents(event))<currPeakSearchDur
                currPeakSearchDur=size(events,1)-spineEvents(event);
            end
            currPeakSearchBackDur=3*PeakSearchDur;                          % maybe do independent peak and std/mean search durations, but this might work too
            if (spineEvents(event)-1)<currPeakSearchBackDur
                currPeakSearchBackDur=spineEvents(event)-1;
            end    
            peakAmp=max(Ntrace(spineEvents(event):spineEvents(event)+currPeakSearchDur,spine));
            if spineEvents(event)-currPeakSearchBackDur<1 || spineEvents(event)+currPeakSearchDur<1
                'help'
            end
            peakAmpThresh=stdMultiplier*std(Ntrace(spineEvents(event)-currPeakSearchBackDur:spineEvents(event)+currPeakSearchDur,spine))...
                +mean(Ntrace(spineEvents(event)-currPeakSearchBackDur:spineEvents(event)+currPeakSearchDur,spine));
            stdThreshMatrix{spine,event}=[spineEvents(event)-currPeakSearchBackDur,spineEvents(event)+currPeakSearchDur,peakAmpThresh];
            
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
    dElevatingTimesSummary(:,spine)=dElevatingTimes(:,spine)+spine-1;
    dNtraceSummary(:,spine)=dNtrace(:,spine)+spine-1;
    eventsSummary(:,spine)=events(:,spine)+spine-1;
end    
% figure;plot(dNtraceSummary,'--');hold on; plot(dElevatingTimesSummary,'-'); % plot the differential signal trace and overlay the binarised trace with the moderate threshold

% figure;plot(NtraceSummary); hold on;                                        % plot the normalised signal trace and highlight all event onsets
% for spine=1:numspines                                                       % loop through all ROIs
%     plot(find(eventsSummary(:,spine)>spine-1),...                           % get the X values of the event onsets for the current ROI in the event Summary - therefore '> spine-1' and not '>1' to counteract the 1 unit spacing in the summary matrix (could probably use normal event matrix here for less confusion)
%         NtraceSummary(eventsSummary(:,spine)>spine-1,spine), 'ko');         % then find the corresponding Y values in the original signal trace of the current ROI and label them with a black circle
% end
%-------------------------------------------------------------------
% find single events/ remove events that are due to spread of signal
% first look for events that happen at the same time and only keep the
% strongest (Ntrace)
% second look for events that occured while other ROIs had an absolute
% difference (first derivative, abs(dNtrace)) above a certain threshold
% and then only keep event if it is the strongest (Ntrace).

% first
% this should be replaced by correlation based approach
singleEvents=zeros(timesteps, numspines);                                   % generate a matrix for single Events
for timestep=1:timesteps                                                    % loop through timesteps to erase all but one event onset at each timepoint
    NumEvents=sum(events(timestep,:));                                      % get the number of events at current timepoint
    if NumEvents>1                                                          % if there is more than one event only keep strongest
        spine=find(Ntrace(timestep,:)==...                                  % find the ROI where the normalised signal trace of the current timepoint is
            max(Ntrace(timestep,events(timestep,:)>0))); %:P                % the maximum of the normalised signal trace of those ROIs (that have an event at the current timepoint) at the current timepoint
        singleEvents(timestep,spine)=1;                                     % hotfix spine(1) would work ... think aobut this hotfix, for problem: if two spines are equal amplitude at same time there is more than one single event
    else
        singleEvents(timestep,:)=events(timestep,:);                        % if there is 1 or 0 events copy the value from the event matrix
    end
end
for spine=1:numspines
    singleEventsSummary(:,spine)=singleEvents(:,spine)+spine-1;             % produce summary for single events
end   
% figure;plot(NtraceSummary); hold on;                                        % plot normalised trace
% for spine=1:numspines
%     plot(find(singleEventsSummary(:,spine)>spine-1),...                     % overlay single events
%         NtraceSummary(singleEventsSummary(:,spine)>spine-1,spine), 'ko'); 
% end

% second
% this is over-selective and has to be replaced by correlation analysis
ssingleEvents=zeros(timesteps, numspines);                                  % create matrix where only strongest events survive                                 
abs_dNtrace=abs(dNtrace);                                                   % unused
[times, spines]=find(abs_dNtrace>0.0100);                                   % unused
dChangingTimes=zeros(timesteps, numspines);
for spine=1:numspines 
    dChangingTimes(times(spines==spine),spine)=1;                           % unused
end
ChopdElevatingTimes=dElevatingTimes(1:end-1,:);                             % dElevatingTimes is same size as Ntrace (normalised trace), but dNtrace is one shorter
% find endpoint of decay phase and plot
Decaythreshold=-0.1;                                                        % unused
EventEnds=zeros(timesteps, numspines); 
EventCorrespondingEnd=zeros(timesteps, numspines); 
for timestep=1:timesteps
    for spine=1:numspines
        if events(timestep,spine)==1                                        % stop of rising phase is encoded in events by -1
            endpoint=timestep;
            while endpoint<timesteps-2 && ...                              %
            (dChangingTimes(endpoint,spine)==1 ||...      
            (Ntrace(endpoint,spine)>= Ntrace(timestep,spine)+slopeThresh-0.0001))
                                         % works like this so getting but maybe re-include and search for end of decay: dChangingTimes(endpoint,spine)==0 ||...dNtrace(endpoint,spine)>0) && this works really well but detects onset of decay
                                    % 
                endpoint=endpoint+1;                                          % 
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

NumEvents=sum(events(:)==1);
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
% end of correlated analysis
set(PureEvents, 'HandleVisibility', 'off');

for timestep=1:timesteps 
    NumEvents=sum(singleEvents(timestep,:));
    if NumEvents>0                                                          % if there is an event at current timepoint only keep if it is strongest in the dNtrace   
        if NumEvents>1
            'error'                                                         % not this error for problem with: if sum(SpineEventTrace-(dNtrace(timestep:timestep2,OtherSpine)))<0
        end
        spine=find(singleEvents(timestep,:)==1);                            % hotfix for error here
        if numel(spine)>1
            'error'
            spine=spine(1);
        end
        timestep2=timestep;                                                 % set event end timepoint as event start timepoint
        while timestep2<timesteps-2 && ...                                  % problem was here now fixed by timestep2<timesteps-2 to adjust both for one final run when criterion is true for the last time and the length of ChopdElevatingTimes being one shorter than timesteps
                ChopdElevatingTimes(timestep2,spine)==1                     % check whether there is another dElevating timepoint at current timepoint after the event onset  
            timestep2=timestep2+1;                                          % update the end of the event in that case
        end
        SpineEventTrace=dNtrace(timestep:timestep2,spine);                  % get the dNtrace values for that event trace
        Biggest=1;                                                          % initialise biggest
        for OtherSpine=1:numspines                                          % loop through all! spines
            
    % make extra condition that OtherSpine EventTrace and 
    % SpineEventTrace must have an overlap
    % i.e. that there most be an event in Trace of the OtherSpine so that
    % either the event of Spine lies within the Event Trace of OtherSpine
    % or vice versa
    % also add some correlation criterion. Only if correlated enough the
    % event should be discarded
    % corrSpines=;
    
    % for correlation analysis get not only rising onset but also endpoint
    % of decay phase
            if sum(SpineEventTrace-...                                      % check whether the sum of differential signal is smaller 
                    (dNtrace(timestep:timestep2,OtherSpine)))<0             % (this is not true if comparing to itself) than the signal of another spine
                Biggest=0;                                                  % if that is the case put biggest to zero
            end
        end
        if Biggest                                                          % if biggest is still one, i.e. if the differential signal is the strongest for the putative event trace
            ssingleEvents(timestep,spine)=1;                                % then keep it
        end
    end
end
for spine=1:numspines                                                       % summary matrix
    ssingleEventsSummary(:,spine)=ssingleEvents(:,spine)+spine-1;
end   
createDatatable(CsingleEvents,EventCorrespondingEnd);
% figure;plot(NtraceSummary); hold on;                                        % plot
% for spine=1:numspines
%     plot(find(ssingleEventsSummary(:,spine)>spine-1),...
%         NtraceSummary(ssingleEventsSummary(:,spine)>spine-1,spine), 'ko'); 
% end

