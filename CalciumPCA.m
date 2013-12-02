function CalciumPCA(ActiveRegions,Ntrace)
% region 95,107,118,183(weird),...,319,329,335,363,385,395 very interesting
% most of them are the big regions
CC=bwconncomp(ActiveRegions>0);  
pixelIdxList=CC.PixelIdxList;
NumActiveRegions=size(pixelIdxList,2);
nt=size(Ntrace,3);
Ntrace=reshape(Ntrace,512*512,nt);
for region=1:NumActiveRegions
    
    pixels=pixelIdxList{region};
%     [X, Y]=ind2sub([512 512],pixels);
    mov=Ntrace(pixels,:);
    npix=numel(pixels);
    if npix>4
       
%         mov = reshape(mov, npix, nt);
        c1 = (mov*mov')/size(mov,2);
        nPCs=5;
        [mixedfilters, CovEvals, percentvar] = cellsort_svd(c1, nPCs, nt, npix);
        figure;
        imagesc(mixedfilters);
        colormap(hot);
        
        nPCs = size(mixedfilters,1);

        Sinv = inv(diag(CovEvals.^(1/2)));

        
        mixedsig = reshape(mov' * mixedfilters' * Sinv, nt, nPCs);
        figure;plot(mixedsig);
        figure;plot(mixedsig(:,1));
    %     covtrace = Ntrace(c1) / npix;
        c1summary{region}=c1;
    end
end


        function [mixedsig, CovEvals, percentvar] = cellsort_svd(covmat, nPCs, nt, npix)
        %-----------------------
        % Perform SVD

        covtrace = trace(covmat) / npix;

        opts.disp = 0;
        opts.issym = 'true';
        if nPCs<size(covmat,1)
            [mixedsig, CovEvals] = eigs(covmat, nPCs, 'LM', opts);  % pca_mixedsig are the temporal signals, mixedsig
        else
            [mixedsig, CovEvals] = eig(covmat);
            CovEvals = diag( sort(diag(CovEvals), 'descend'));
            nPCs = size(CovEvals,1);
        end
        CovEvals = diag(CovEvals);
        if nnz(CovEvals<=0)
            nPCs = nPCs - nnz(CovEvals<=0);
            fprintf(['Throwing out ',num2str(nnz(CovEvals<0)),' negative eigenvalues; new # of PCs = ',num2str(nPCs),'. \n']);
            mixedsig = mixedsig(:,CovEvals>0);
            CovEvals = CovEvals(CovEvals>0);
        end

        mixedsig = mixedsig' * nt;
        CovEvals = CovEvals / npix;

        percentvar = 100*sum(CovEvals)/covtrace;
        fprintf([' First ',num2str(nPCs),' PCs contain ',num2str(percentvar,3),'%% of the variance.\n'])
