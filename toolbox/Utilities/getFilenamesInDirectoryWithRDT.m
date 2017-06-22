function filenames = getFilenamesInDirectoryWithRDT(directory)
% filenames = getFilenamesInDirectoryWithRDT(directory)
% 
% Returns the filenames of the folder loaded on the Remote Data Toolbox
% server. In order for this work with the other code in this repository, it
% looks for the phrase 'OpticalImageData' in the directory string and takes
% the substring (inclusive) after it to look for the directory on the RDT
% server.
%
% Inputs:
%     directory  -  diectory located on the RDT server to look at
%
% Outputs:
%     filenames  -  cell array of file names in the 'directory' on RDT
%                   sorted alphanumerically
%
% 4/28/17  xd  wrote it

%% Find 'OpticalImageData'
startIdx = strfind(directory,'OpticalImageData');
targetDirectory = directory(startIdx:end);

%% Load RDT Client and look up path
rd = RdtClient(getpref('BLIlluminationDiscrimCalcsValidation','remoteDataToolboxConfig'));
rd.crp(fullfile('/resources',targetDirectory));

%% Return list of filenames
fileList = rd.listArtifacts('type','mat');
filenames = {fileList(:).artifactId};
filenames = cellfun(@(X) strcat(X,'.mat'),filenames,'UniformOutput',false);

%% Sort file names
% We first sort it alphanumerically, then sort by number of characters in the
% filename. This puts names with double digits after names with single
% digits.
filenames = sort(filenames);
[~,b] = sort(cellfun(@numel,filenames));
filenames = filenames(b);

end

