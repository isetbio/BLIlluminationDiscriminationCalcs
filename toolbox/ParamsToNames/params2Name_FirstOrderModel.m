function name = params2Name_FirstOrderModel(params)
% name = params2Name_FirstOrderModel(params)
% 
% This function takes the parameters of the first order model and generates
% an appropriate file name. This allows us to have some consistent method
% of data organization.
%
% 9/9/16  xd  wrote it

name = [params.calcIDStr 'FirstOrderModel'];

% OI folder information
name = [name '_' params.cacheFolderList{2}];

% Cone density and other properties of the mosaic
name = sprintf([name '_LMS_%2.2f_%2.2f_%2.2f'],params.spatialDensity(2),params.spatialDensity(3),params.spatialDensity(4));
name = sprintf([name '_FOV%2.2f'],params.sensorFOV);

if params.usePCA
    name = sprintf([name '_PCA%d'],params.numPCA);
end

% Things about data and classifier
name = [name '_' dataFunctionText(params.dFunction) '_' classifierFunctionText(params.cFunction)];

% Add number of training samples
name = sprintf([name '_NumSamples%d'],params.trainingSetSize);

end

