function [pairChain1, pairChain2, chainNumPt, chainPointIdxHead] = genPairChainStruct(contourPair, chNoVec)

pairChain1.pointSet = [];
pairChain1.point2Chain = [];
if nargout > 1
    pairChain2.pointSet = [];
    pairChain2.point2Chain = [];
end

if nargin < 2
    chNoVec = 1:length(contourPair);
end

numChain = length(chNoVec);

for it_ch=1:numChain
    chNo = chNoVec(it_ch);
    numPt = size(contourPair{chNo},1);    
    pairChain1.pointSet = [pairChain1.pointSet; round(contourPair{chNo}(:,1:2))];
    pairChain1.point2Chain = [pairChain1.point2Chain; ones(numPt, 1)*chNo, (1:numPt)'];

    if nargout > 1
        pairChain2.pointSet = [pairChain2.pointSet; round(contourPair{chNo}(:,3:4))];    
        pairChain2.point2Chain = [pairChain2.point2Chain; ones(numPt, 1)*chNo, (1:numPt)'];
    end
end

if nargout > 2
    chainNumPt = cellfun('size', contourPair, 1);
end

if nargout > 3
    chainPointIdxHead = [0; cumsum(chainNumPt)];
end
