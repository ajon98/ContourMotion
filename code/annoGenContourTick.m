function myTick = annoGenContourTick(myContour, tickPtGap)

markVec = find(myContour.ptMark);
numMark = length(markVec);

myTick = 1;
for i=2:numMark
    idx = myTick(end):tickPtGap:markVec(i);
    if isempty(idx)
        idx = 1;
    end
    if length(idx) == 1
        idx(end+1) = markVec(i);
    end
    if idx(end) + tickPtGap/2 > markVec(i)
        idx(end) = markVec(i);
    else
        idx(end+1) = markVec(i);
    end
    myTick = [myTick, idx(2:end)];
end
