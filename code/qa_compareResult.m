%%
gl_resRoot = '../results/contourFlow';
gl_compRoot = '../interData/comp';
gl_annoRoot = '../groundTruth';

%%
thErrorAlongTangent = 3:10;
thErrorAlongNormal = 4;

gl_dataSetting = data_getSetting();
gl_numSeq = gl_dataSetting.numSeq;
for gl_iSeq = 1:gl_numSeq
    seqName = gl_dataSetting.dataInfo{gl_iSeq}{1};
    compResFileName = sprintf('%s/cf_%s.mat', gl_compRoot, seqName);
    if exist(compResFileName, 'file')
        continue;
    end
    
    %% load the ground truth
    load(sprintf('%s/%s.mat', gl_annoRoot, seqName));
    [annoContourTrk, annoContourFrmInfo] = annoGenContourPointTraj(xxx_annoMoveContourSet, xxx_annoMoveContourSetInfo, xxx_annoMoveContourSetStatus, 2);
    numContour = size(annoContourFrmInfo,1);
    
    %% load the results of contour flow
    load(sprintf('%s/contour_%s_LDOF__Mo.mat', gl_resRoot, seqName));
    
    contoutMchTrk = cell(numContour, 1);
    for ic = 1:numContour
        tickFrmMchTrk = [];
        for it_th = 1:length(thErrorAlongTangent)
            tickFrmMchTrk(:,:,it_th) = qaCalcOverlappedLenTraj(annoContourTrk{ic}, annoContourFrmInfo(ic,:), cfTrackInfo, cfTrackData, thErrorAlongTangent(it_th), thErrorAlongNormal);
            %         showContourIdx = ic;
            %         showTickFrmMchTrk = tickFrmMchTrk(:,:,it_th);
            %         qaShowGroundTruthMatchTraj;
            %         pause;
        end
        
        contoutMchTrk{ic} = tickFrmMchTrk;
    end
        
    save(compResFileName, 'contoutMchTrk');
    disp(sprintf('compare: %s', seqName));
end % it_seq

disp('done');


