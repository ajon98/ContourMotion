#include <math.h>
#include "ForestLayerGenMex.h"

ForestLayerGenMex::ForestLayerGenMex()
{
}

ForestLayerGenMex::~ForestLayerGenMex()
{
}

void ForestLayerGenMex::onFatalError(const char *msg)
{
	mexErrMsgTxt(msg);
}


void ForestLayerGenMex::genLayerMex(int nrhs, const mxArray *prhs[], int sIdx, const mxArray *pField)
{
	int numNode, maxDegree, numPair;
	int *pairII, *pairJJ;
	double *pairW;
	
    mxArray *pData;
    
    if (nrhs<3 + sIdx){
        mexErrMsgTxt("error @ input.");
    }

	//  create a pointer to the input matrix y
    pairII = (int *)mxGetPr(prhs[sIdx]); // int *
    numPair = mxGetM(prhs[sIdx]);

	pairJJ = pairII + numPair;

    pairW = mxGetPr(prhs[sIdx+1]); // double *

    numNode = (int)(mxGetScalar(prhs[sIdx+2])+0.5); // int

    if (mxGetFieldNumber(pField, "mstMaxDegree") >= 0){
        pData = mxGetField(pField, 0, "mstMaxDegree");
        maxDegree = (int) (mxGetScalar(pData)+0.5); // int
    }else maxDegree = -1;

    if (!setupMemory(numNode, maxDegree))
    {
        mexErrMsgTxt("error @ memory alloc.");
    }

	calcForestLayer(numNode, numPair, pairII, pairJJ, pairW);
}

// [treeLayer, nodeParent, nodeWeight]
int ForestLayerGenMex::outputLayer(int nlhs, mxArray *plhs[], int outIdx)
{
	int i, j, pos;
	mxArray *tmpArr;
	double *outPtr;

	plhs[outIdx] = mxCreateCellMatrix(g_numLayer, 1);

	for (i=0; i<g_numLayer; i++) {
		tmpArr = mxCreateDoubleMatrix(g_layLen[i], 1, mxREAL);
		outPtr = mxGetPr(tmpArr);

		pos = g_layHead[i];
		for (j=0; j<g_layLen[i]; j++, pos++){
			outPtr[j] = g_layerNode[pos] + 1;
		}

		mxSetCell(plhs[outIdx], i, tmpArr);
	}
	outIdx++;

	if (nlhs > 1){
		plhs[outIdx] = mxCreateDoubleMatrix(g_numNode, 1, mxREAL);
		outPtr = mxGetPr(plhs[outIdx]);
		for (j=0; j<g_numNode; j++, pos++){
			outPtr[j] = g_nodeParent[j] + 1;
		}
		outIdx++;
	}

	if (nlhs > 2){
		plhs[outIdx] = mxCreateDoubleMatrix(g_numNode, 1, mxREAL);
		outPtr = mxGetPr(plhs[outIdx]);
		for (j=0; j<g_numNode; j++, pos++){
			outPtr[j] = g_nodeWeight[j];
		}
		outIdx++;
	}

	return outIdx;
}
