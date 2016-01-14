%%
gl_resRoot = '../results/contourFlow';
gl_tmpRoot = '../interData/tmp';

%%

gl_dataSetting = data_getSetting();
gl_numSeq = gl_dataSetting.numSeq;
for gl_iSeq = 1:gl_numSeq
    resFileName = sprintf('%s/contour_%s_LDOF__Mo.mat', gl_resRoot, gl_dataSetting.dataInfo{gl_iSeq}{1});
    
    if ~exist(resFileName, 'file')
        continue;
    end
    
    imOrgSeq = data_loadImageSeq('../', gl_dataSetting, gl_iSeq);
    
    load(resFileName);
    cfShowFrameContourFlow;
end % it_seq
