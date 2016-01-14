%%
gl_resRoot = '../results/contourFlow';
gl_compRoot = '../interData/comp';
gl_annoRoot = '../groundTruth';

%%
gl_dataSetting = data_getSetting();
gl_numSeq = gl_dataSetting.numSeq;

frmLenVec = 1:50;
numStatFrmLen = length(frmLenVec);
annoContourFrmInfo = [];
allStatMat = [];

for gl_iSeq = 1:gl_numSeq
    seqName = gl_dataSetting.dataInfo{gl_iSeq}{1};
    compResFileName = sprintf('%s/cf_%s.mat', gl_compRoot, seqName);
    
    %% load cf-groundtruth matcing results
    load(compResFileName); % contoutMchTrk
    
    annoContourFrmInfo = [annoContourFrmInfo; [cellfun('size', contoutMchTrk, 1), cellfun('size', contoutMchTrk, 2)]];
    
    numContour = length(contoutMchTrk);
    numStatErrorTh = size(contoutMchTrk{1}, 3);
    
    statMat = zeros(numStatFrmLen, numStatErrorTh);    
    %% for each annotated contour
    for ic = 1:numContour
        %% for each error threshold
        for it_th = 1:numStatErrorTh
            tickFrmMchTrk = contoutMchTrk{ic}(:,:,it_th);
            numTick = size(tickFrmMchTrk,2);
            
            coverLenVec = tickFrmMchTrk(tickFrmMchTrk > 0);
            %% for each minimum frame overlap
            for it_len = 1:numStatFrmLen
                minLen = frmLenVec(it_len);
                % count the coverage
                statMat(it_len, it_th) = statMat(it_len, it_th) + sum(coverLenVec(coverLenVec >= minLen));
            end
        end
    end    
    allStatMat(:,:,gl_iSeq) = statMat;
end % it_seq

%% show

numStatFrmLen = size(allStatMat, 1);
numStatErrorTh = size(allStatMat, 2);

lenSum = zeros(numStatFrmLen, 1);
for it_len = 1:numStatFrmLen
    minLen = frmLenVec(it_len);
    idx = find(annoContourFrmInfo(:,1) >= minLen);
    lenSum(it_len) = sum(annoContourFrmInfo(idx,1).*annoContourFrmInfo(idx,2));
end
lenSum = repmat(lenSum, 1, numStatErrorTh);
pr = sum(allStatMat(:,:,:), 3)./lenSum;
plotPr = pr(10,:); %% minimum temporal overlap is 10

figure;
hold on;
plot(3:10, plotPr*100, 'r', 'LineWidth', 3);

set(gca,'XTick',3:10);
set(gca,'YTick',0:10:100);
ylim([0 100]);
xlim([3 10]);
xlabel('Error Threshold (pixel)');
ylabel('Coverage (%)');
grid on

