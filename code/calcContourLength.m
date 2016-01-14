function lenInfo = calcContourLength(pt)


dc = pt(2:end, :)-pt(1:end-1, :);
dc = sqrt(sum(dc.*dc,2));

lenInfo(1) = sum(dc);
lenInfo(2) = mean(dc);
