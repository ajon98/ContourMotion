function [contourTrk, contourFrmInfo, contourLenInfo] = annoGenContourPointTraj(contourSet, contourSetInfo, contourSetStatus, gap)

contourTrk = {};
contourFrmInfo = [];
contourLenInfo = [];

numSet = length(contourSet);
if numSet < 1
    return;
end

for i = 1:numSet
    stopRange = contourSetInfo(i,2:3);
    frmVec = find(contourSetStatus(i,:));
    frm1 = max(frmVec(1), stopRange(1));
    frm2 = min(frmVec(end), stopRange(2));
    
    if frm2 - frm1 + 1 <= 2
        continue;
    end
    
    contourLen = zeros(frm2, 2);
    for iFrm = frm1:frm2
        contourLen(iFrm, :) = calcContourLength(contourSet{i}{iFrm}.ptOrg);
    end
    
    [maxContourLen, iStartFrm] = max(contourLen(:,1));
    contourLenInfo(end+1) = maxContourLen;
    curvStep = contourLen(iStartFrm, 2);
    tickPtGap = max(round(gap/curvStep),1);
    tickVec = annoGenContourTick(contourSet{i}{iStartFrm}, tickPtGap);
    
    numTick = length(tickVec);
    contourTicks = zeros(frm2, numTick);
    contourTicks(iStartFrm, :) = tickVec;

    contourTicks = annoUpdateContourTicks(contourSet{i}, contourTicks, frm1);
    contourTicks = annoUpdateContourTicks(contourSet{i}, contourTicks, frm2);
    
    contourFrmInfo(end+1, :) = [frm1, frm2];
    cTrk = zeros(numTick, frm2-frm1+1, 4);
    for iFrm = frm1:frm2
        ptNorm = splineSmoothNormal(contourSet{i}{iFrm}.ptOrg, 0);
        cTrk(:, iFrm-frm1+1, 1:2) = contourSet{i}{iFrm}.ptOrg(contourTicks(iFrm, :), :);
        cTrk(:, iFrm-frm1+1, 3:4) = ptNorm(contourTicks(iFrm, :), :);
    end
    
    contourTrk{end+1} = cTrk;
end
