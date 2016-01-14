#include <math.h>
#include <stdlib.h>
#include <string.h>

#include "ForestLayerGen.h"


ForestLayerGen::ForestLayerGen()
{
	g_auxIntBuf = 0;
	g_allocIntBufSize = -1;
	g_auxFloatBuf = 0;
	g_allocFloatBufSize = -1;

	gn_maxNode = -1;
}

ForestLayerGen::~ForestLayerGen()
{
	clearMemory();
}

void ForestLayerGen::onFatalError(const char *msg)
{
}

void ForestLayerGen::clearMemory(void)
{
    delete g_auxIntBuf;
    delete g_auxFloatBuf;

    g_auxIntBuf = 0;
    g_allocIntBufSize = -1;
    
    g_auxFloatBuf = 0;
    g_allocFloatBufSize = -1;    
}

int ForestLayerGen::setupMemory(int numNode, int maxDegree)
{
	int allocIntSize, allocFloatSize;

	if (numNode > gn_maxNode) gn_maxNode = numNode + 100;

	if (maxDegree > 0) gn_maxDegree = maxDegree;
	else gn_maxDegree = 32;

	gn_maxLayer = gn_maxNode*2;
	gn_maxBufSize = gn_maxNode*2;
                
    // alloc mem
    allocIntSize = gn_maxNode*3 + gn_maxBufSize + gn_maxLayer*2 + gn_maxNode*gn_maxDegree;
    allocFloatSize = gn_maxNode;
    
    if (allocIntSize > g_allocIntBufSize){
        delete g_auxIntBuf;
        g_allocIntBufSize = allocIntSize;
        g_auxIntBuf = new int[allocIntSize];
    }
    
    if (allocFloatSize > g_allocFloatBufSize){
        delete g_auxFloatBuf;
        g_allocFloatBufSize = allocFloatSize;
        g_auxFloatBuf = new double[allocFloatSize];
    }

    if (!g_auxFloatBuf || !g_auxIntBuf) return 0;
    
    // init float mem
    g_nodeWeight = g_auxFloatBuf;
  
    // init int mem
    g_nodeDegree = g_auxIntBuf;
    g_nodeMask = g_nodeDegree + gn_maxNode;
    g_nodeParent = g_nodeMask + gn_maxNode;
    g_layerNode = g_nodeParent + gn_maxNode;
    g_layHead = g_layerNode + gn_maxBufSize;
    g_layLen = g_layHead + gn_maxLayer;
    g_pairListPerNode = g_layLen + gn_maxLayer;

    return 1;
}

void ForestLayerGen::calcForestLayer(int numNode, int numPair, int *pairII, int *pairJJ, double *pairW)
{
	int i, iNode, off, numLeft;
	int k, bufIdx, pIdx, iParent, offPar;

	g_numNode = numNode;

	for (i=0; i<numNode; i++){
		g_nodeParent[i] = -1;
		g_nodeMask[i] = -1;
		g_nodeDegree[i] = 0;
	}

	for (i=0; i<numPair; i++){
		iNode = pairII[i]-1;
		off = iNode*gn_maxDegree + g_nodeDegree[iNode];
		g_pairListPerNode[off] = i+1;
		g_nodeDegree[iNode]++;
		if (g_nodeDegree[iNode] >= gn_maxDegree){
			onFatalError("error @ maxDegree");
		}

		iNode = pairJJ[i]-1;
		off = iNode*gn_maxDegree + g_nodeDegree[iNode];
		g_pairListPerNode[off] = -(i+1);
		g_nodeDegree[iNode]++;
		if (g_nodeDegree[iNode] >= gn_maxDegree){
			onFatalError("error @ maxDegree");
		}
	}

	numLeft = numNode;

	g_numLayer = 0;
	bufIdx = 0;

	while (numLeft > 0){
		g_layHead[g_numLayer] = bufIdx;
		off = 0;
		for (i=0; i<numNode; i++, off+=gn_maxDegree){
			if (g_nodeDegree[i] != 1 || g_nodeMask[i] == g_numLayer) continue;

			if (g_pairListPerNode[off] > 0){
				pIdx = g_pairListPerNode[off]-1;
				iParent = pairJJ[pIdx] - 1;
			}else{
				pIdx = -g_pairListPerNode[off]-1;
				iParent = pairII[pIdx] - 1;
			}

			offPar = iParent*gn_maxDegree;
			for (k=0; k<g_nodeDegree[iParent]; k++){
				if (abs(g_pairListPerNode[offPar + k])-1 == pIdx){
					k++;
					break;
				}
			}
			for (; k<g_nodeDegree[iParent]; k++){
				g_pairListPerNode[offPar + k - 1] = g_pairListPerNode[offPar + k];
			}

			g_layerNode[bufIdx] = i;
			g_nodeParent[i] = iParent;
			g_nodeWeight[i] = pairW[pIdx];
			bufIdx++;

			if (bufIdx >= gn_maxBufSize){
				onFatalError("error @ maxBufSize");
			}

			g_nodeDegree[iParent]--;
			g_nodeDegree[i]--;

			if (g_nodeDegree[iParent] < 0 || g_nodeDegree[i] < 0){
				k = 0;
			}

			g_nodeMask[i] = g_numLayer;
			g_nodeMask[iParent] = g_numLayer;
		}

		g_layLen[g_numLayer] = bufIdx - g_layHead[g_numLayer];
		g_numLayer++;

		if (g_numLayer >= numNode){
			k = 0;
		}

		if (g_numLayer >= gn_maxLayer){
			onFatalError("error @ maxLayer");
		}

		numLeft = 0;
		for (k=0; k<numNode; k++){
			if (g_nodeDegree[k]) numLeft++;
		}
	}

	g_layHead[g_numLayer] = bufIdx;
	for (k=0; k<numNode; k++){
		if (g_nodeParent[k] >= 0) continue;

		g_layerNode[bufIdx] = k;
		bufIdx++;

		if (bufIdx >= gn_maxBufSize){
			onFatalError("error @ maxBufSize");
		}
	}
	g_layLen[g_numLayer] = bufIdx - g_layHead[g_numLayer];
	g_numLayer++;
}
