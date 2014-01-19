function createDatatable(CsingleEvents,EventCorrespondingEnd)
scrsz = get(0,'ScreenSize');
tbl=figure('name','events','OuterPosition',[0.75*scrsz(3),0*scrsz(4),0.25*scrsz(3),0.5*scrsz(4)-70]);
numEvents=sum(CsingleEvents(:));
[numtimesteps,numspines]=size(CsingleEvents);
rnames=[1:numEvents];
    
    cnames{1}='spine';
    cnames{2}='duration';
    cnames{4}='auto(0),del(1),add(2)';
    cnames{3}='start';
    % cnames{5}='180';
    % cnames{6}='225';
    % cnames{7}='270';
    % cnames{8}='315';
dat=zeros(numEvents,4);
event=1;
for spine=1:numspines
    for timestep=1:numtimesteps
        if CsingleEvents(timestep,spine)==1
            dat(event,1)=spine;
            dat(event,2)=EventCorrespondingEnd(timestep,spine)-timestep;
            dat(event,3)=timestep;
            dat(event,4)=0;
            event=event+1;
        end
    end
end
t=uitable('Parent',tbl,'ColumnName',cnames,'Data',dat,'Position',[20 20 0.25*scrsz(3)-40 0.5*scrsz(4)-70-70],'ColumnWidth',{50,50,50,150},'RowName',rnames);
    set(tbl, 'HandleVisibility', 'off');