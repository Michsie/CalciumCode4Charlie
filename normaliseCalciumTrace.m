function NCaclciumSignal=normaliseCalciumTrace(RawTrace,data_length,numNeurons,numberOfRepeats)
NCaclciumSignal=zeros(data_length,numNeurons,numberOfRepeats);           % initialise backgroundfilterd matrix
for repeat=1:numberOfRepeats
    for col=1:numNeurons
        NCaclciumSignal(1:data_length,col,repeat)=...                    % delta F over F function
    (RawTrace(:,col,repeat)- mean(RawTrace(1:5,col,repeat)))./...
    (mean(RawTrace(1:5,col,repeat)));          
    end
end