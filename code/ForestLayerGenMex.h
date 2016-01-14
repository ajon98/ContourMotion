#pragma once

#include "ForestLayerGen.h"
#include "mex.h"

class ForestLayerGenMex: public ForestLayerGen
{
public:
	ForestLayerGenMex();
	virtual ~ForestLayerGenMex();

	void genLayerMex(int nrhs, const mxArray *prhs[], int sIdx, const mxArray *pField);

	int outputLayer(int nlhs, mxArray *plhs[], int outIdx);

protected:
	virtual void onFatalError(const char *msg);
};
