function Experiment()

warning off;

%% Init Params, Paths & Directories
parameters = ExperimentParameters;      % Init of Parameters
path(Utilities.getCOSFIREFolder(parameters),path);    % Setting COSFIRE Path
path(Utilities.getGABORFolder(parameters),path);      % Setting Gabor Path
%%
        %% Experiment setup
        % Setting up batch name and testing directory
        parameters.TestingDirectory = Utilities.getTestingDirectory(parameters);
        
        % If the right folder structure is in place.
        Utilities.SetupFolderEnviroment(parameters.TestingFolder);
        %%

        %% Configuration

        % Parameters
        models = dir([Utilities.getModelsDirectory(parameters), ['*' parameters.ModelsExtension]]);
        noOfSymbols = size(models,1);
        
        %Configuration of operators
        configuration = ConfigureOperators(parameters, noOfSymbols);
        %%

        %% Training
        %Populating Training set
        trainingSet = TrainOperators(parameters, configuration, noOfSymbols);
        %%
        
        %% Testing
        %Testing operators
        TestOperators(parameters, ...
                      configuration,...
                      trainingSet,...
                      noOfSymbols);
        %% 
        
    % Playing sine tone to signal end of process
    Utilities.Signal()
end

