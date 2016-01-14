#include "ForestLayerGen.cpp"
#include "ForestLayerGenMex.cpp"

static ForestLayerGenMex myLayerGen;

void mexFunction( int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{    
	const mxArray *pOptField;
	int outIdx;

	pOptField = prhs[0];
	myLayerGen.genLayerMex(nrhs, prhs, 1, pOptField);

	outIdx = 0;
    outIdx = myLayerGen.outputLayer(nlhs, plhs, outIdx);
}
