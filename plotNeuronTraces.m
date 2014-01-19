function plotNeuronTraces(Firstspine,backgroundfiltered,CsingleEvents,events,stdRemovedEvents,onsetTimingRemovedEvents)
scrsz = get(0,'ScreenSize');
meanFiltered=mean(backgroundfiltered,3);

% figure('Position',[1 scrsz(4)/2 scrsz(3)/2 scrsz(4)/2])
% numWindows=8;
maxWindows=14;
rightWindows=0;
numWindows=numel(Firstspine);
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
    plot(meanFiltered(:,spine),'color','b'); title(strcat('normalised spine ',num2str(spine)));
    hold on;
    % single events
    plot(find(CsingleEvents(:,spine)>0),...
        backgroundfiltered(CsingleEvents(:,spine)>0,spine),'LineStyle','none','LineWidth',1.1,'MarkerSize',10,'Marker','o','MarkerEdgeColor','r');
    % removed duplicate events
    plot(find(CsingleEvents(:,spine)<=0 & events(:,spine)>0),...
        backgroundfiltered((CsingleEvents(:,spine)<=0 & events(:,spine)>0),spine),'LineStyle','none','LineWidth',1.1,'MarkerSize',10,'Marker','o','MarkerEdgeColor','g');
    % removed std events
    plot(find(stdRemovedEvents(:,spine)>0),...
        backgroundfiltered((stdRemovedEvents(:,spine)>0),spine),'LineStyle','none','LineWidth',1.1,'MarkerSize',10,'Marker','o','MarkerEdgeColor','c');
    % removed onset events
    plot(find(onsetTimingRemovedEvents(:,spine)>0),...
        backgroundfiltered((onsetTimingRemovedEvents(:,spine)>0),spine),'LineStyle','none','LineWidth',1.0,'MarkerSize',10,'Marker','o','MarkerEdgeColor','m');
    
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
    plot(meanFiltered(:,spine),'color','b'); title(strcat('normalised spine ',num2str(spine)));
    hold on;
    plot(find(CsingleEvents(:,spine)>0),...
        meanFiltered(CsingleEvents(:,spine)>0,spine),'LineStyle','none','LineWidth',1.1,'MarkerSize',10,'Marker','o','MarkerEdgeColor','r');
    plot(find(CsingleEvents(:,spine)<=0 & events(:,spine)>0),...
        backgroundfiltered((CsingleEvents(:,spine)<=0 & events(:,spine)>0),spine),'LineStyle','none','LineWidth',1.1,'MarkerSize',10,'Marker','o','MarkerEdgeColor','g');
    % removed std events
    plot(find(stdRemovedEvents(:,spine)>0),...
        backgroundfiltered((stdRemovedEvents(:,spine)>0),spine),'LineStyle','none','LineWidth',1.1,'MarkerSize',10,'Marker','o','MarkerEdgeColor','c');
    % removed onset events
    plot(find(onsetTimingRemovedEvents(:,spine)>0),...
        backgroundfiltered((onsetTimingRemovedEvents(:,spine)>0),spine),'LineStyle','none','LineWidth',1.0,'MarkerSize',10,'Marker','o','MarkerEdgeColor','m');
    
    
    if ndims(backgroundfiltered)==3
        stdFiltered=std(backgroundfiltered(:,spine,:),0,3);
        ciplot(meanFiltered(:,spine)-stdFiltered,meanFiltered(:,spine)+stdFiltered);
    end
end