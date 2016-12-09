function illcalcsValidateFullAll(varargin)
% Full data check (no figures, no publish) of all validation functions
%
%    validateFullAll(param,val, ...)
%
% Possible parameters are (need full list of options from somewhere ...
% please indicate here at least with a pointer)
%
%    'verbosity' -    high, med, low ...
%    'numeric tolerance'
%    'graph mismatched data'
%    'generate plots'
%
% Examples:
%   validateFullAll('verbosity','high');
%   validateFullAll('Numeric Tolerance',1000*eps);
%   validateFullAll('generate plots',true);


    close all; 

    %% We will use preferences for the project at hand
    UnitTest.usePreferencesForProject('BLIlluminationDiscrimCalcsValidation', 'reset');

    %% Set preferences for this function

    % Run time error behavior
    % valid options are: 'rethrowExceptionAndAbort', 'catchExceptionAndContinue'
    UnitTest.setPref('onRunTimeErrorBehavior', 'catchExceptionAndContinue');

    % Plot generation
    UnitTest.setPref('generatePlots',  false);
    UnitTest.setPref('closeFigsOnInit', true);

    %% Verbosity Level
    % valid options are: 'none', min', 'low', 'med', 'high', 'max'
    UnitTest.setPref('verbosity', 'high');

    %% Whether to plot data that do not agree with the ground truth
    UnitTest.setPref('graphMismatchedData', true);

    %% Adjust parameters based on input arguments
    if ~isempty(varargin)
    elseif ~isodd(length(varargin))
        for ii=1:2:length(varargin)
            param = ieParamFormat(varargin{ii});
            val   = varargin{ii+1};
            switch(param)
                case 'verbosity'
                    UnitTest.setPref('verbosity',val);
                case 'numerictolerance'
                    UnitTest.setPref('numericTolerance', val);
                case 'graphMismatchedData'
                    UnitTest.setPref('graphMismatchedData', val);
                case 'generatePlots'
                    UnitTest.setPref('generatePlots',  val);
                otherwise
                    error('Unknown validation string %s\n',varargin{ii+1});
            end
        end
    else
        error('Odd number of arguments, must be param/val pairs');
    end

    %% Print current values of validation prefs
    UnitTest.listPrefs();

    %% What to validate
    listingScript = UnitTest.getPref('listingScript');
    vScriptsList = eval(listingScript);

    %% How to validate
    % Run a FULL validation session (comparing actual data)
    UnitTest.runValidationSession(vScriptsList, 'FULLONLY');

end