function idx = findNearestIdx(myX, hisX)

numMy = length(myX);
numHis = length(hisX);

dist = abs(repmat(myX(:), 1, numHis) - repmat(hisX(:)', numMy, 1));

[~, idx] = min(dist, [], 2);
