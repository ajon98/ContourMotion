gl_annoRoot = '../groundTruth';

gl_dataSetting = data_getSetting();
gl_numSeq = gl_dataSetting.numSeq;
for gl_iSeq = 1:gl_numSeq
    seqName = gl_dataSetting.dataInfo{gl_iSeq}{1};
    annoFileName = sprintf('%s/%s.mat', gl_annoRoot, seqName);
    if ~exist(annoFileName, 'file')
        continue;
    end
    load(annoFileName);
    [annoContourTrk, annoContourFrmInfo] = annoGenContourPointTraj(xxx_annoMoveContourSet, xxx_annoMoveContourSetInfo, xxx_annoMoveContourSetStatus, 2);
    
    imOrgSeq = data_loadImageSeq('../', gl_dataSetting, gl_iSeq);
    
    numContour = size(annoContourFrmInfo,1);
    for ic = 1:numContour
        frm1 = annoContourFrmInfo(ic,1);
        frm2 = annoContourFrmInfo(ic,2);
        for it_f=frm1:frm2
            imOrg = imOrgSeq{it_f};
            figure(1);
            clf;
            imshow(imOrg);
            hold on;
            
            k = it_f - frm1 + 1;
            plot(annoContourTrk{ic}(:,k,1), annoContourTrk{ic}(:,k,2), 'r');
            plot(annoContourTrk{ic}(1:3:end,k,1), annoContourTrk{ic}(1:3:end,k,2), 'r.');
            th = title(sprintf('seq: %s, contour %d, frm %d', seqName, ic, it_f));
            set(th,'interpreter','none');
            pause;
        end
    end
end


