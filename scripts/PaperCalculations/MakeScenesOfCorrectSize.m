%% MakeScenesOfCorrectSize



calcParams.calcIDStr = 'ConstantFullImage';
calcParams.cacheFolderList = {'Constant' 'Constant_CorrectSize'};
calcParams = assignCalibrationFile(calcParams);
calcParams = updateCropRect(calcParams);
calcParams.S = [380 8 51]; 

constFov = 20;

convertRGBImagesToScenesResize(calcParams,constFov,1);

calcParams.calcIDStr = 'Neutral_FullImage';
calcParams.cacheFolderList = {'Neutral' 'Neutral_CorrectSize'};
calcParams = assignCalibrationFile(calcParams);
calcParams = updateCropRect(calcParams);
calcParams.S = [380 8 51]; 

chromFov = 18.6;

convertRGBImagesToScenesResize(calcParams,chromFov,1);

calcParams.calcIDStr = 'NM1_FullImage';
calcParams.cacheFolderList = {'NM1' 'NM1_CorrectSize'};
calcParams = assignCalibrationFile(calcParams);
calcParams = updateCropRect(calcParams);
calcParams.S = [380 8 51]; 

convertRGBImagesToScenesResize(calcParams,chromFov,1);

calcParams.calcIDStr = 'NM2_FullImage';
calcParams.cacheFolderList = {'NM2' 'NM2_CorrectSize'};
calcParams = assignCalibrationFile(calcParams);
calcParams = updateCropRect(calcParams);
calcParams.S = [380 8 51]; 

convertRGBImagesToScenesResize(calcParams,chromFov,1);