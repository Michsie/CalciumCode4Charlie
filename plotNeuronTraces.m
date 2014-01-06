function plotNeuronTraces(Firstspine,backgroundfiltered,CsingleEvents)
scrsz = get(0,'ScreenSize');
meanFiltered=mean(backgroundfiltered,3);

% figure('Position',[1 scrsz(4)/2 scrsz(3)/2 scrsz(4)/2])
numWindows=8;
for spinestep=1:numWindows
    spine=Firstspine+spinestep-1;
    figure('Toolbar','none','MenuBar','none','name',strcat('spine',num2str(spine),' normalised trace'),...
        'Position',[10,(8-spinestep)*(scrsz(4)-10)/8+10,scrsz(3)/2.7-20,scrsz(4)/8-30]);
    plot(meanFiltered(:,spine),'color','b'); title(strcat('normalised spine ',num2str(spine)));
    hold on;
    plot(find(CsingleEvents(:,spine)>0),...
        backgroundfiltered(CsingleEvents(:,spine)>0,spine), 'ro');
    if ndims(backgroundfiltered)==3
        stdFiltered=std(backgroundfiltered(:,spine,:),0,3);
        ciplot(meanFiltered(:,spine)-stdFiltered,meanFiltered(:,spine)+stdFiltered);
    end
end
for spinestep=1:numWindows
    spine=Firstspine+spinestep+7;
    figure('Toolbar','none','MenuBar','none','name',strcat('spine',num2str(spine),' normalised trace'),...
        'Position',[scrsz(3)/2.7...                                         % not sure if those ... are necessary
        ,(8-spinestep)*(scrsz(4)-10)/8+10,scrsz(3)/2.7-20,scrsz(4)/8-30]);
    plot(meanFiltered(:,spine),'color','b'); title(strcat('normalised spine ',num2str(spine)));
    hold on;
    plot(find(CsingleEvents(:,spine)>0),...
        meanFiltered(CsingleEvents(:,spine)>0,spine), 'ro');
    if ndims(backgroundfiltered)==3
        stdFiltered=std(backgroundfiltered(:,spine,:),0,3);
        ciplot(meanFiltered(:,spine)-stdFiltered,meanFiltered(:,spine)+stdFiltered);
    end
end