function params = ExperimentParameters

%%  Checkpoint Switches
params.loadConfigurationFromFile    = 0;
params.loadTrainingFromFile         = 0;
%%

%% Operator Configuration parameters
params.NFiltersPerProtoType         = 3;
params.minNumberOfTuplesPerFilter   = 5;
params.minNumberOfDistinctOrientationsPerFilter   = 2;
%%

%% General directory Parameters
% Whether folder is OSX or WIN
params.OS                           = 'OSX';

% Name of folders & extension for Model & Test Images
params.ModelsFolder                 = 'sketches25f-models';
params.ModelsExtension              = '.tiff';
params.TestingFolder                = 'sketches25f-level1';
params.TestingExtension             = '.tiff';
%%

%% Windows Directory Parameters
% General Paths
params.WIN.COSFIREFolder                = '';
params.WIN.GaborFolder                  = ''; 
params.WIN.DataSetsPath                 = '';

% Data set directories
params.WIN.ModelsDirectory              = [params.WIN.DataSetsPath params.TestingFolder '/' params.ModelsFolder '/'];
params.WIN.TestingDirectory             = [params.WIN.DataSetsPath params.TestingFolder '/' params.TestingFolder '/'];
%%

%% OSX Directory Parameters
params.OSX.COSFIREFolder                = '/Users/lukeagius/Documents/Dropbox/1. Documents Repository/Education/University/5th year/Thesis/Documentation/Thesis Document/4. Final Report/CDContents/Implementation/COSFIREFilter/COSFIRE/';
params.OSX.GaborFolder                  = '/Users/lukeagius/Documents/Dropbox/1. Documents Repository/Education/University/5th year/Thesis/Documentation/Thesis Document/4. Final Report/CDContents/Implementation/COSFIREFilter/Gabor/'; 
params.OSX.DataSetsPath                 = '/Users/lukeagius/Documents/Dropbox/1. Documents Repository/Education/University/5th year/Thesis/Documentation/Thesis Document/4. Final Report/CDContents/Datasets/Category1/';

% Data set directories
params.OSX.ModelsDirectory              = [params.OSX.DataSetsPath params.ModelsFolder '/'];
params.OSX.TestingDirectory             = [params.OSX.DataSetsPath params.TestingFolder '/'];
%%

%% COSFIRE Parameters

% Retrieving Parameters for COSFIRE Filter, to be accessed through our
% parameters file. In this case getting the rho list
if strcmp(params.OS,'WIN') == 1
    path(params.WIN.COSFIREFolder,path);
else
    path(params.OSX.COSFIREFolder,path);
end

params2 = Parameters;
params.rholist                      = params2.COSFIRE.rholist;
end