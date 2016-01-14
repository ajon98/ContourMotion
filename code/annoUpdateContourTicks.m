function contourTicks = annoUpdateContourTicks(contourSet, contourTicks, curFrmIdx)

if contourTicks(curFrmIdx, 1) > 0.5
    return;
end
% need update
frmIdx = find(contourTicks(:, 1) > 0.5);
off = abs(frmIdx - curFrmIdx);
[frmGap, ii] = min(off);
prevFrm = frmIdx(ii);

frmOff = ((curFrmIdx - prevFrm)>0)*2 - 1;
fromFrm = prevFrm;
for iterFrm = 1:frmGap
    toFrm = fromFrm + frmOff;
    fromTickVec = contourTicks(fromFrm, :);
    uniFromTickVec = unique(fromTickVec);
    fromTickMark = contourSet{fromFrm}.ptMark(uniFromTickVec);
    fromTickMarkVec = find(fromTickMark);
    numMark = length(fromTickMarkVec);

    myMarkVec = find(contourSet{toFrm}.ptMark);
    
    prevMarkTickIdx = 1;
    myTick = 1;
    myPrevCurvCoord = 0;
    for i=2:numMark
        curMarkTickPtIdx = uniFromTickVec(fromTickMarkVec(i));
        idx = find(curMarkTickPtIdx == fromTickVec);
        curMarkTickIdx = max(idx);
        % prevPtIdx ~ curPtIdx
        fromPrevCurvCoord = contourSet{fromFrm}.ptCurvCoord(fromTickVec(prevMarkTickIdx));
        fromCurCurvCoord = contourSet{fromFrm}.ptCurvCoord(fromTickVec(curMarkTickIdx));
        
        tickSite = prevMarkTickIdx+1:curMarkTickIdx-1;
        fromSiteCurvCoord = contourSet{fromFrm}.ptCurvCoord(fromTickVec(tickSite));
        fromSiteCurvRatio = (fromSiteCurvCoord - fromPrevCurvCoord)/(fromCurCurvCoord - fromPrevCurvCoord);

        myCurCurvCoord = contourSet{toFrm}.ptCurvCoord(myMarkVec(i));
        
        mySiteCurvCoord = fromSiteCurvRatio*(myCurCurvCoord - myPrevCurvCoord) + myPrevCurvCoord;
        ptIdx = findNearestIdx(mySiteCurvCoord, contourSet{toFrm}.ptCurvCoord);
        myTick = [myTick, ptIdx', myMarkVec(i)];
        
        prevMarkTickIdx = curMarkTickIdx;
        myPrevCurvCoord = myCurCurvCoord;
    end
    
    contourTicks(toFrm, :) = myTick;
    
    fromFrm = toFrm;
end
