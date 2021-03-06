function spineHandleList=plotNeuronTraces(Firstspine,data)

backgroundfiltered=data.Ntrace;
CsingleEvents=data.CsingleEvents;
events=data.events;
stdRemovedEvents=data.stdRemovedEvents;
onsetTimingRemovedEvents=data.onsetTimingRemovedEvents;
EventEnds=data.EventEnds;
minDurRemovedEvents=data.minDurRemovedEvents;
stdThreshMatrix=data.stdThreshMatrix;
scrsz = get(0,'ScreenSize');
meanFiltered=mean(backgroundfiltered,3);
% data.events=events;
% data.CsingleEvents=CsingleEvents;
% data.Ntrace=Ntrace;
% data.onsetTimingRemovedEvents=onsetTimingRemovedEvents;
% data.stdRemovedEvents=stdRemovedEvents;
% data.minDurRemovedEvents=minDurRemovedEvents;
% data.EventEnds=EventEnds;
% data.stdThreshMatrix=stdThreshMatrix;
% data.tableFigureHandle=tableFigureHandle;
% data.tableHandle=tableHandle;

% figure('Position',[1 scrsz(4)/2 scrsz(3)/2 scrsz(4)/2])
% numWindows=8;
maxWindows=14;
rightWindows=0;
numWindows=numel(Firstspine);
spineHandleList=zeros(numWindows,2);
if numWindows>maxWindows
    Firstspine=Firstspine(1:maxWindows);
    numWindows=maxWindows;
end
if numWindows>maxWindows/2
    leftWindows=maxWindows/2;
    rightWindows=numWindows-leftWindows;
else
    leftWindows=numWindows;
end
bottomScreenDist=90;
topScreenDist=25;
FigureNameAndLabelHeight=40;
for spinestep=1:leftWindows
    spine=Firstspine(spinestep);
    figure('Toolbar','none','MenuBar','none','name',strcat('spine',num2str(spine),' normalised trace'),...
        'Position',[10,(maxWindows/2-spinestep)*(scrsz(4)-(bottomScreenDist+topScreenDist))/(maxWindows/2)+bottomScreenDist,scrsz(3)/2.7-20,scrsz(4)/(maxWindows/2)-FigureNameAndLabelHeight]);
    spineHandleList(spinestep,:)=[spine,gcf];
    plot(meanFiltered(:,spine),'color','b'); title(strcat('normalised spine ',num2str(spine)));
    hold on;
    % single events
    plot(find(CsingleEvents(:,spine)>0),...
        backgroundfiltered(CsingleEvents(:,spine)>0,spine),'LineStyle','none','LineWidth',1.1,'MarkerSize',10,'Marker','o','MarkerEdgeColor','r');
    % event ends
    plot(find(EventEnds(:,spine)>0),...
        backgroundfiltered(EventEnds(:,spine)>0,spine),'LineStyle','none','LineWidth',1.1,'MarkerSize',10,'Marker','x','MarkerEdgeColor','r');
    % removed duplicate events
    plot(find(CsingleEvents(:,spine)<=0 & events(:,spine)>0),...
        backgroundfiltered((CsingleEvents(:,spine)<=0 & events(:,spine)>0),spine),'LineStyle','none','LineWidth',1.1,'MarkerSize',10,'Marker','o','MarkerEdgeColor','g');
    % removed std events
    plot(find(stdRemovedEvents(:,spine)>0),...
        backgroundfiltered((stdRemovedEvents(:,spine)>0),spine),'LineStyle','none','LineWidth',1.1,'MarkerSize',10,'Marker','o','MarkerEdgeColor','c');
    % 2*std+mean thresholds
    event=1;
    while numel(stdThreshMatrix{spine,event})
        plot(stdThreshMatrix{spine,event}(1):stdThreshMatrix{spine,event}(2),...
               stdThreshMatrix{spine,event}(3)*ones(stdThreshMatrix{spine,event}(2)-stdThreshMatrix{spine,event}(1)+1,1),'-r');
           event=event+1;
    end
    
    % removed onset events
%     plot(find(onsetTimingRemovedEvents(:,spine)>0),...
%         backgroundfiltered((onsetTimingRemovedEvents(:,spine)>0),spine),'LineStyle','none','LineWidth',1.0,'MarkerSize',10,'Marker','o','MarkerEdgeColor','m');
    % removed duration events
    plot(find(minDurRemovedEvents(:,spine)>0),...
        backgroundfiltered((minDurRemovedEvents(:,spine)>0),spine),'LineStyle','none','LineWidth',1.2,'MarkerSize',10,'Marker','o','MarkerEdgeColor','y');
    
    if ndims(backgroundfiltered)==3
        stdFiltered=std(backgroundfiltered(:,spine,:),0,3);
        ciplot(meanFiltered(:,spine)-stdFiltered,meanFiltered(:,spine)+stdFiltered);
    end
end
for spinestep=1:rightWindows
    spine=Firstspine(spinestep+maxWindows/2);
    figure('Toolbar','none','MenuBar','none','name',strcat('spine',num2str(spine),' normalised trace'),...
        'Position',[scrsz(3)/2.7...                                         % not sure if those ... are necessary
        ,(maxWindows/2-spinestep)*(scrsz(4)-(bottomScreenDist+topScreenDist))/(maxWindows/2)+bottomScreenDist,scrsz(3)/2.7-20,scrsz(4)/(maxWindows/2)-FigureNameAndLabelHeight]);
    spineHandleList(spinestep+maxWindows/2,:)=[spine,gcf];
    plot(meanFiltered(:,spine),'color','b'); title(strcat('normalised spine ',num2str(spine)));
    hold on;
    plot(find(CsingleEvents(:,spine)>0),...
        meanFiltered(CsingleEvents(:,spine)>0,spine),'LineStyle','none','LineWidth',1.1,'MarkerSize',10,'Marker','o','MarkerEdgeColor','r');
    % event ends
    plot(find(EventEnds(:,spine)>0),...
        backgroundfiltered(EventEnds(:,spine)>0,spine),'LineStyle','none','LineWidth',1.1,'MarkerSize',10,'Marker','x','MarkerEdgeColor','r');
    plot(find(CsingleEvents(:,spine)<=0 & events(:,spine)>0),...
        backgroundfiltered((CsingleEvents(:,spine)<=0 & events(:,spine)>0),spine),'LineStyle','none','LineWidth',1.1,'MarkerSize',10,'Marker','o','MarkerEdgeColor','g');
    % removed std events
    plot(find(stdRemovedEvents(:,spine)>0),...
        backgroundfiltered((stdRemovedEvents(:,spine)>0),spine),'LineStyle','none','LineWidth',1.1,'MarkerSize',10,'Marker','o','MarkerEdgeColor','c');
    
    % 2*std+mean thresholds
    event=1;
    while numel(stdThreshMatrix{spine,event})
        plot(stdThreshMatrix{spine,event}(1):stdThreshMatrix{spine,event}(2),...
               stdThreshMatrix{spine,event}(3)*ones(stdThreshMatrix{spine,event}(2)-stdThreshMatrix{spine,event}(1)+1,1),'-r');
           event=event+1;
    end
    
    % removed onset events
%     plot(find(onsetTimingRemovedEvents(:,spine)>0),...
%         backgroundfiltered((onsetTimingRemovedEvents(:,spine)>0),spine),'LineStyle','none','LineWidth',1.0,'MarkerSize',10,'Marker','o','MarkerEdgeColor','m');
    % removed duration events
    plot(find(minDurRemovedEvents(:,spine)>0),...
        backgroundfiltered((minDurRemovedEvents(:,spine)>0),spine),'LineStyle','none','LineWidth',1.2,'MarkerSize',10,'Marker','o','MarkerEdgeColor','y');
    
    
    if ndims(backgroundfiltered)==3
        stdFiltered=std(backgroundfiltered(:,spine,:),0,3);
        ciplot(meanFiltered(:,spine)-stdFiltered,meanFiltered(:,spine)+stdFiltered);
    end
end