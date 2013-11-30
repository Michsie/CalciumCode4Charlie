function analyseCalciumSignals(framesPerSecond,numberOfRepeats)
% Computes spikes from raw fluorescence traces
if nargin<2                                                                 % analyseCalcium can be called with or without inputs for frequency and number of repeats
    framesPerSecond=input('acquisition frequency (Hz): ');
    numberOfRepeats=input('number of repeated acquisition you want to analyse (put 1 for an individual analysis): ');
end
% -------------------------------------------------------
try 
    FinalImage=openTifStack('uint16');                                       % calls function to prompt for the tif Stack containing the raw frames
catch
    'tif stack couldnt be openend'
end
% -------------------------------------------------------
PromptText='openOverviewJpeg (f0)';                                              % get an overview image for the ROIs
[Jpeg_filename, data_pathname] = uigetfile('*.*', PromptText);
cd(data_pathname);
ROIoverview=importdata(Jpeg_filename);
% -------------------------------------------------------


plotOrNotToPlot='NotToplot';                                                % use 'plot' to activate plot of trace etc


for repeat=1:numberOfRepeats                                                % loop through repeats and get data input
    PromptText='openROItraceFile';                                              % Get metamorph data
    [data_filename, data_pathname] = uigetfile('*.*', PromptText);
    cd(data_pathname);

    data=importdata(data_filename);                                         
    [data_length,numColumns]=size(data);
    numNeurons=numColumns;  
    
    if repeat==1                                                            % initialise matrices
        RawTrace=zeros(data_length,numNeurons,numberOfRepeats);
    end   
   
    RawTrace(:,:,repeat)=data();                                               % make matrix for neurons 
end
 NCalciumSignal=normaliseCalciumTrace(RawTrace,data_length,numNeurons,numberOfRepeats);
%-----------------------------------------------------
% [meanFiltered,spikes,stimTraces,thresholds]=FindSpikes...                   %finds spikes and returns chunked orientation data as well as the spike thresholds and mean data
% (backgroundfiltered,numNeurons,numOrientations,initialFramesToDiscard,... 
%     FramesPerOrientation,framesDuringStim,blackFramesBeforeStim,...
%     plotOrNotToPlot,orientationData);

% for neuron=1:numNeurons
%     PreferredOrientation{neuron}=find(spikes(neuron,:)==...                 % PreferredOrientation could be used in future version
%         max(spikes(neuron,:)));     
% end

% create3dPlot(meanFiltered);                                                 % creates a 3d mesh graph of the filtered and aligned Data

h=analyseCalciumSignalsGUI(NCalciumSignal,ROIoverview,FinalImage);
scrsz = get(0,'ScreenSize');
movegui(h,[scrsz(3)*3.3/5,scrsz(4)*1.7/3]);

%-----------------------------------------------------
%-----------------------------------------------------
% make text file output of spike matrix
% cd(data_pathname);
% filename=strcat(Jpeg_filename(1:end-4),'_results');
% fileID = fopen(filename,'w');
% 
% fprintf(fileID,'%6s %3s %3s %3s %3s %3s %3s %3s %3s\r\n','neuron','0','45','90','135','180','225','270','315');
% fprintf(fileID,'%6.0f %3.0f %3.0f %3.0f %3.0f %3.0f %3.0f %3.0f %3.0f\r\n',[[1:size(spikes,1)]',spikes]');
% fclose(fileID); 