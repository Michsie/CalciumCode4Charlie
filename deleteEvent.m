function [delTimestep,data]=deleteEvent...
    (data,spineHandleList)
Ntrace=data.Ntrace;
CsingleEvents=data.CsingleEvents;
events=data.events;
TableFigureHandle=data.tableFigureHandle;
TableHandle=data.tableHandle;

mousepress = waitforbuttonpress;
axishandle=gca;
axes(axishandle);
figure(get(axishandle, 'Parent'));
spineHandle=gcf;
spinestep=find(spineHandleList(:,2)==spineHandle);
spine=spineHandleList(spinestep,1);
mousepress=waitforbuttonpress;
currpt = get(axishandle, 'CurrentPoint');
x=currpt(2,1);
% y=currpt(2,2);
clickpos=round(x);
eventnotfound=1;
timestep=0;
if events(clickpos,spine)==1
    events(clickpos,spine)=0;
    CsingleEvents(clickpos,spine)=0;
    delTimestep=clickpos;
else
    
    while eventnotfound==1
        preEventFound=0;
        postEventFound=0;
        timestep=timestep+1;
        if events(clickpos-timestep,spine)==1
            preEventFound=1;
            delTimestep=clickpos-timestep;            
        end
        if events(clickpos+timestep,spine)==1
            postEventFound=1;
            delTimestep=clickpos+timestep;            
        end
        if preEventFound && postEventFound
            if clickpos-x>0
                preEventFound=0;delTimestep=clickpos+timestep;
            else
                postEventFound=0;delTimestep=clickpos-timestep;
            end
        end
        eventnotfound=~(preEventFound||postEventFound);   
        
    end
    events(delTimestep,spine)=0;
    CsingleEvents(delTimestep,spine)=0;
end
data.events=events;
data.CsingleEvents=CsingleEvents;
hold on
plot(delTimestep,Ntrace(delTimestep,spine),'LineStyle','none',...
    'LineWidth',1.2,'MarkerSize',20,'Marker','x','MarkerEdgeColor','k');
figure(TableFigureHandle);