function [nodeOrder, treeLayer, nodeParent, nodeWeight]  = mstNodeOrdering(trkConn)

numNode = size(trkConn, 1);
[ti, tj, ts] = find(trkConn);
UG = sparse(ti, tj, ts, numNode, numNode);
[ST] = graphminspantree(UG, 'method', 'Kruskal');
[ti,tj,ts] = find(ST);
mst = [ti,tj,ts];

para.mstMaxDegree = 64;
if max(sum(ST>0)) > para.mstMaxDegree
    error('mstMaxDegree @ mstNodeOrdering');
end

[treeLayer, nodeParent, nodeWeight] = mstGenForestLayer(para, int32(mst(:, 1:2)), mst(:, 3), numNode);

nodeOrder = zeros(numNode, 1);

rootNode = treeLayer{end};
nodeOrder(rootNode) = 1;

nLayers = length(treeLayer);
for it_lay=nLayers-1:-1:1
    tNode = treeLayer{it_lay};
    tParent = nodeParent(tNode);
    nodeOrder(tNode) = nodeOrder(tParent)+1;
end
