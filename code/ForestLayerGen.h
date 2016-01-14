#pragma once

class ForestLayerGen{

public:
	ForestLayerGen();
	virtual ~ForestLayerGen();

	void clearMemory();
	int setupMemory(int numNode, int maxDegree);
	
	void calcForestLayer(int numNode, int numPair, int *pairII, int *pairJJ, double *pairW);

protected:
	virtual void onFatalError(const char *msg);

protected:
	// for memory alloc
	int *g_auxIntBuf, g_allocIntBufSize;
	double *g_auxFloatBuf;
	int g_allocFloatBufSize;

	int gn_maxDegree, gn_maxBufSize, gn_maxLayer, gn_maxNode;

	int *g_pairListPerNode; // gn_maxNode*gn_maxDegree
	int *g_nodeDegree, *g_nodeParent, *g_nodeMask; // gn_maxNode
	double *g_nodeWeight; // gn_maxNode

	int *g_layerNode; // gn_maxBufSize
	int *g_layHead, *g_layLen; // gn_maxLayer
	int g_numLayer;

	int g_numNode;
};
