function FinalImage=openTifStack(uint8or16)
% opens Tif Stack and returns images stack matrix

PromptText='open Tif Stack';
[data_filename, data_pathname] = uigetfile('*.*', PromptText);
cd(data_pathname);
try 
    data=load(strcat(data_filename(1:end-4),'Quick'));                      % checks if tif stack has been openened before
    FinalImage=data.FinalImage;
catch
FileTif=data_filename;
InfoImage=imfinfo(FileTif);
mImage=InfoImage(1).Width;
nImage=InfoImage(1).Height;
NumberImages=length(InfoImage);
FinalImage=zeros(nImage,mImage,NumberImages,uint8or16);
 
TifLink = Tiff(FileTif, 'r');
for i=1:NumberImages
   TifLink.setDirectory(i);
   FinalImage(:,:,i)=TifLink.read();
end
TifLink.close();
cd(data_pathname);
save(strcat(data_filename(1:end-4),'Quick'),'FinalImage');                  % saves the image stack matrix for future quick access
end