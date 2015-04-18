function params = ExperimentParameters

%%  Checkpoint Switches
params.loadConfigurationFromFile    = 1;
params.loadTrainingFromFile         = 1;
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
params.ModelsFolder                 = 'models';
params.ModelsExtension              = '.tif';
params.TestingFolder                = 'NoiseB';
params.TestingExtension             = '.tiff';
%%

%% Windows Directory Parameters
% General Paths
params.WIN.COSFIREFolder                = '../COSFIREFilter/COSFIRE/';
params.WIN.GaborFolder                  = '../COSFIREFilter/Gabor/'; 
params.WIN.DataSetsPath                 = '../../../Data sets/Symbols Datasets/Sketched Symbols/Category 2/';

% Data set directories
params.WIN.ModelsDirectory              = [params.WIN.DataSetsPath params.TestingFolder '/' params.ModelsFolder '/'];
params.WIN.TestingDirectory             = [params.WIN.DataSetsPath params.TestingFolder '/' params.TestingFolder '/'];
%%

%% OSX Directory Parameters
params.OSX.COSFIREFolder                = '/Users/lukeagius/Documents/Dropbox/1. Documents Repository/Education/University/5th year/Thesis/Code base/COSFIREFilter/COSFIRE/';
params.OSX.GaborFolder                  = '/Users/lukeagius/Documents/Dropbox/1. Documents Repository/Education/University/5th year/Thesis/Code base/COSFIREFilter/Gabor/'; 
params.OSX.DataSetsPath                 = '/Users/lukeagius/Documents/Dropbox/1. Documents Repository/Education/University/5th year/Thesis/Data sets/Symbols Datasets/Sketched Symbols/Category 2/';

                                          
% Data set directories
params.OSX.ModelsDirectory              = [params.OSX.DataSetsPath params.TestingFolder '/' params.ModelsFolder '/'];
params.OSX.TestingDirectory             = [params.OSX.DataSetsPath params.TestingFolder '/' params.TestingFolder '/'];
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

%%

%% Deprecated Parameters
% Batch Related Parameters
% params.BatchName                    = ''; 
%%
end