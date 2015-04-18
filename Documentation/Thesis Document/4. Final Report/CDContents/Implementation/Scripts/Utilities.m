classdef Utilities
    methods(Static)
        
        parameters = ExperimentParameters;      % Init of Parameters
        
        %% OPERATOR related Utilities
        % Saves the operators to images.
        function SaveOperators(operator,ModelImage,outPutFile,operatorsCoords)

            % Visualize the structure of the given COSFIRE operator. The orientations
            % are illustrated by ellipses and the blurring functions are illustrated by
            % 2D Gaussian blobs

            params = operator.params;
            exparams = ExperimentParameters;

            maxrho = max(operator.tuples(3,:));
            maxsigma = params.COSFIRE.sigma0 + params.COSFIRE.alpha*maxrho;    
            radius = ceil((maxrho + (maxsigma*3)));

            offset = [radius radius];   
            dim = (2 * radius) + 1;

            %figure;
            axis off;

            sig = zeros(dim);            
            for j = 1:size(operator.tuples,2)
                rho = operator.tuples(3,j);
                sigma = params.COSFIRE.sigma0 + params.COSFIRE.alpha*rho;
                [x y] = pol2cart(operator.tuples(4,j),rho);            
                g = gaussian(sigma,sigma,0,[dim dim],[round(offset(1)-y),round(offset(2)+x)]);
                sig = max(sig,g);
            end

            modelImageForCoordinate = cell(1,exparams.NFiltersPerProtoType); 
            
            for i=1:length(modelImageForCoordinate)
                modelImageForCoordinate{i} = Utilities.printRhoList(ModelImage, operatorsCoords{i}(1), operatorsCoords{i}(2), params.COSFIRE.rholist);
            end
            
            % Init resize factor;
            resizeFactor = 0;

            % Getting size of testing and operator images
            testingImageSize    = size(modelImageForCoordinate{1},1);
            operatorImageSize   = size(sig,1);

            % Getting the larger of the above two values
            [value index]       = max([testingImageSize operatorImageSize]);

            % Depending on which is larger, it is resized with it's size divided by the
            % size of the smallest image. If bigger image is of size 302 and smaller
            % image is of size 128 then the resize factor is (128/302).
            if index == 1
                resizeFactor = operatorImageSize(1)/testingImageSize(1);
                
                for i=1:length(modelImageForCoordinate)
                    modelImageForCoordinate{i} = imresize(modelImageForCoordinate{i},resizeFactor);
                end
            else
                resizeFactor = testingImageSize(1)/operatorImageSize(1);
                sig = imresize(sig,resizeFactor);
            end

            opss = cell(1,exparams.NFiltersPerProtoType); 
            for i=1:length(opss)
                opss{i} = imfuse(sig,im2uint8(modelImageForCoordinate{i}));
            end
            
                      
            ops = imfuse(opss{1},opss{2});
            
            if length(opss) > 2
                for i=3:length(opss)
                    ops = imfuse(ops,opss{i});
                end
            end

            % Finally fusing togather the above ops output with the image containg the
            % rho list
            imwrite(imfuse(ops,rho), outPutFile);
        end
        
        % This function gets a set of well distanced points (according to
        % NFiltersPerProtoType) within the model image 
        function result = getWellDistancedCoordinates()
            
            % Init Parameters
            params = ExperimentParameters;
            
            % Init Cell of operator Coordinates according to NFiltersPerProtoType
            coordinates = cell(1,params.NFiltersPerProtoType);    
            
            % Populating cell with random coordinates
            for i = 1:length(coordinates)
                coordinates{i} = [randi([1, 256]) randi([1, 256])];
            end
            
            % Looping through the number of points in cell coordinates
            for currentPoint=1:length(coordinates)
                
                % Looping through all the previous coordinate sets up to
                % current Point
                for tempPoint=1:currentPoint-1
                    
                    % while the distance between currentPoint and tempPoint
                    % is smaller or equal to params.DistanceBetweenOperators
                    % re-assign new set of coordinates for currentPoint
                    while(dist(coordinates{currentPoint}, coordinates{tempPoint}') <= params.DistanceBetweenOperators)
                        coordinates{currentPoint} = [randi([1, 256]) randi([1, 256])];
                    end
                end
            end
            
            % Finally return the results
            result = coordinates;
        end
        
        function saveFalsePositive(BatchName, testingImage, modelImage, fileName)
            
            % Saving false positive to file.
            imwrite(imfuse(testingImage,modelImage,'montage'), ['..\Final Results\' BatchName '\Result Output\' fileName]);
        end
        %%
        
        %% MODEL IMAGE related Utilities
        % This function takes in the Model Image and prints upon it the 
        % declared rho list
        function result = printRhoList(ModelImage,x, y, rhoList)

        % Init list of circles
        circles = int32(zeros(length(rhoList),3));

        % For each element in rho list, the circles matrix is being populated.
        for j=1:length(rhoList),
            circles(j,1) = x;
            circles(j,2) = y;
            circles(j,3) = rhoList(j);
        end

        % Converting image to RGB
        RGB = repmat(ModelImage,[1,1,3]);

        % Color of circle borders
        red = uint8([255 0 0]); 

        % Init Shapre inserter and specify circles
        shapeInserter = vision.ShapeInserter('Shape','Circles','BorderColor','Custom','CustomBorderColor',red);

        % Mesh togather the circles and the image.
        %imwrite(step(shapeInserter, RGB, circles),outputPath);
        result = step(shapeInserter, RGB, circles);
        end 
        
        % This function analyses the model image folder to ensure that the
        % selected rho list covers all the models.
        function result = rhoAnalyser(modelsDir, ModelsExtension, rhoList)
            flag = 0;
            
            % Getting models
            models = dir([modelsDir, ['*' ModelsExtension]]);
            for i=1:size(models,1), 
                % Resizing model image and converting to uint8
                % m = imresize(im2uint8(m),0.5);
                m = im2uint8(imresize(imread([modelsDir models(i).name]),0.5));
                
                % Init circles to draw in image according to rho list.
                circles = int32(zeros(length(rhoList),3));
                for j=1:length(rhoList),
                    circles(j,1) = 128;
                    circles(j,2) = 128;
                    circles(j,3) = rhoList(j);
                end

                % Init 2D matrix of size 256x256 and setting all to 1
                c = zeros(256,256); c(:) = 1;

                % Init image which will show the circles.
                circ = repmat(c,[1,1,3]);
                %red = uint8([0 0 0]);

                % Init the shape inserter
                shapeInserter = vision.ShapeInserter('Shape','Circles','BorderColor','Custom','CustomBorderColor',uint8([0 0 0]));

                % Inserting circles into matrix C
                c = step(shapeInserter, im2uint8(circ), circles);
                c = c(:,:,2);
                %m = im2uint8(m);

                % Init 2D matrix x of size 256x256, and setting all values to
                % 256.
                x = zeros(256,256); %x(:) = 255;

                % Looping through size of image model, if both the current
                % value in both matrices are 0 then set corresponding value in
                % X to 255.
                for o=1:256,
                    for p=1:256,
                        if c(o,p) == 0
                            if m(o,p) == 0
                            x(o,p) = 255;
                            end
                        end
                    end
                end
                %x2 = ~x;

                B = bwboundaries(x);
                if length(B) == 0
                    subplot(1,4,1), imshow(c);
                    for r=1:length(rhoList)
                        text(128,128+rhoList(r),strcat('\color{red}',num2str(rhoList(r))));
                    end
                    
                    subplot(1,4,2), imshow(m);
                    subplot(1,4,3), imshow(imfuse(c,m,'diff')); 
                    for r=1:length(rhoList)
                        text(128,128+rhoList(r),strcat('\color{red}',num2str(rhoList(r))));
                    end
                    
                    subplot(1,4,4), imshow(x);
                    text(10,10,strcat('\color{green}Intersections :',num2str(length(B))))
                    hold on
                    for k = 1:length(B)
                        boundary = B{k};
                        plot(boundary(:,2), boundary(:,1), 'g', 'LineWidth', 0.2)
                    end
                
                    flag = 1;
                end
                display([models(i).name ':' num2str(length(B)) ' hits']);
            end
            result = flag;
        end
        %%
        
        %% FOLDER related Utilities
        % This function sets up the initial folder structure to hold final 
        % and intermediate results
        function SetupFolderEnviroment(batchName)
            try
                % If Final Results folder does not exist
                if exist('..\Final Results', 'dir') == 0
                    % Create it
                    mkdir('..\Final Results')  
                end

                % If Intermediate results folder does not exist
                if exist('..\Intermediate Results', 'dir') == 0
                    % Create it along with the other sub folders.
                    mkdir('..\Intermediate Results')
                end
                    mkdir(['..\Intermediate Results\' batchName '\COSFIRE Operators'])
                    mkdir(['..\Intermediate Results\' batchName '\Training data'])
                    mkdir(['..\Intermediate Results\' batchName '\Check Points'])


                % Preping Final Results folder
                Utilities.createResultFolder(batchName);

                % Preping Intermediate Results folder
                Utilities.createIntermediateFolder(batchName);

            catch err
                %error(err.identifier);
            end
        end

        % This function preps up the Final Results folder for the current
        % experiment
        function createResultFolder(batchName)
            try
                % Checks if folder exists, if it doesnt
                if exist(['..\Final Results\' batchName], 'dir') == 0

                    % Create the necessary folders
                    mkdir(['..\Final Results\' batchName]);
                    mkdir(['..\Final Results\' batchName '\Result Output'])
                    edit(['..\Final Results\' batchName '\' batchName '-Results.txt'])
                end
            catch err
                error(err.identifier);
            end
        end

        % This function preps up the Intermediate results folder for the 
        % current experiment.
        function createIntermediateFolder(batchName)
            try
                % Checks if folder exists, if it doesnt
                if exist(['..\Intermediate Results\' batchName '\COSFIRE Operators\'], 'dir') == 0
                    % Create it
                    mkdir(['..\Intermediate Results\' batchName '\COSFIRE Operators\'])
                end

                % Checks if folder exists, if it doesnt
                if exist(['..\Intermediate Results\' batchName '\Check Points\'], 'dir') == 0
                    % Create it
                    mkdir(['..\Intermediate Results\' batchName '\Check Points\'])
                end
                
                % Checks if folder exists, if it doesnt
                if exist(['..\Intermediate Results\' batchName '\Test Image Outputs(MAX)\'], 'dir') == 0
                    % Create it
                    mkdir(['..\Intermediate Results\' batchName '\Test Image Outputs(MAX)\'])
                end
                
            catch err
                error(err.identifier);
            end
        end
        %%
        
        %% IO Utilities
        % This function reads the test image's related xml file and
        % extracts the expected target
        function targetResult = ReadXMLV1(fileName)
                % Loading XML document from the specified file.
                xDoc = xmlread(fileName);

                % Importing Java Xpath libraries
                import javax.xml.xpath.*

                % Init new Xpath instance
                factory = XPathFactory.newInstance;
                xpath = factory.newXPath;

                % Building xpath expression to query xDoc for a specific node
                expression = xpath.compile('gom.OHL/ov/o/gom.std.OSymbol');

                % Get Target node
                symbolNode = expression.evaluate(xDoc, XPathConstants.NODE);

                % Return target attribute in the target node.
                targetResult = symbolNode.getAttributes.item(1).getTextContent;
        end
        
        % This function reads the test images set related xml file and
        % extracts the expected target for each test image
        function resultModel = ReadXMLV2(testImageName)
            try
               
                p = ExperimentParameters;
                filepath = '';
               
                if strcmp(p.OS,'WIN') == 1
                    filepath = [p.WIN.DataSetsPath p.TestingFolder '/' p.TestingFolder '.gt.xml' ];
                else
                    filepath = [p.OSX.DataSetsPath p.TestingFolder '/' p.TestingFolder '.gt.xml' ];
                end
                
                
                xDoc = xmlread(filepath);

                % Importing Java Xpath libraries
                import javax.xml.xpath.*

                % Init new Xpath instance
                factory = XPathFactory.newInstance;
                xpath = factory.newXPath;

                trueModelID = xpath.compile(['//test/testimage[@name = "' testImageName '"]/refmodel']).evaluate(xDoc, XPathConstants.NODE).getAttributes.item(0).getTextContent;
                resultModel = xpath.compile(['//test/model[@id = "' char(trueModelID) '"]']).evaluate(xDoc, XPathConstants.NODE).getAttributes.item(1).getTextContent;
                
            catch err
                error(err.identifier);
            end
        end
        
        % This function writes training data to excel.
        function writeTrainingData(BatchName, objectToWrite, excelRowNumber)
            try
            xlswrite(['../Intermediate Results/' BatchName '/Training data/' BatchName '.xls'],objectToWrite,'sheet1',['A' num2str(excelRowNumber) ':ET' num2str(excelRowNumber)])
            catch err
                error(err.identifier);
            end
        end
        
        % Outputs an image showing the training data.
        function visualizeTrainingData(listOfCOSFIREOutputs, BatchName)
            
            temp = zeros(150,450);
            for i=1:150
                temp(i,:) = listOfCOSFIREOutputs{i};
            end
            
            imwrite(temp, ['../Intermediate Results/' BatchName '/Training data/' BatchName '.jpg']);
        end
        
        % Displays and appends time taken for experiment to run.
        function appendElapsedTimeToFile(BatchName, timeTaken)
            FileID = fopen(['..\Final Results\' BatchName '\' BatchName '-Results.txt'],'a');
            fprintf(FileID,(datestr(datenum(0,0,0,0,0,timeTaken),'HH:MM:SS'))); 
            fclose(FileID);
        end
        
        % Appends the true positives and false positives to the result file.
        function appendTPFP(BatchName,TP, FP)
            % Finally display and write results to file.
            
            p = ExperimentParameters;
            if strcmp(p.OS,'WIN') == 1
                FileID = fopen(['..\Final Results\' BatchName '\' BatchName '-Results.txt'],'a');
            else
                currentPath = pwd;
                textFilePath = [strrep(currentPath,'Scripts','') 'Final Results\' BatchName '\' BatchName '-Results2.txt'];
                FileID = fopen(textFilePath,'a');
            end
            
            
            fprintf(FileID,'\r\n'); display(' ')
            fprintf(FileID,['True positives : ' num2str(TP) '\r\n']); display(['True positives : ' num2str(TP)]);
            fprintf(FileID,['False positives : ' num2str(FP) '\r\n']); display(['False positives : ' num2str(FP)]);
            fclose(FileID);
        end
        
        % Appends result to file.
        function appendResultToFile(BatchName,TestImageName,ModelImageName, result)
            p = ExperimentParameters;
            if strcmp(p.OS,'WIN') == 1
                FileID = fopen(['..\Final Results\' BatchName '\' BatchName '-Results.txt'],'a');
            else
                currentPath = pwd;
                textFilePath = [strrep(currentPath,'Scripts','') 'Final Results/' BatchName '/' BatchName '-Results.txt'];
                FileID = fopen(textFilePath,'a');
            end
            
            display([TestImageName ' is closest to ' ModelImageName ' - ' result]); 
            fprintf(FileID,[TestImageName ' is closest to ' ModelImageName ' - ' result '\r\n']);
            fclose(FileID);
        end
        
        % Appends any text to file.
        function appendTxtToFile(path, text)
            FileID = fopen(path,'a');
            fprintf(FileID,[text '\r\n']);
            fclose(FileID);
        end
        %%
        
        %% Directory Properties
        function result = getCOSFIREFolder(params)
            if strcmp(params.OS,'WIN') == 1
                result = params.WIN.COSFIREFolder;
            else
                result = params.OSX.COSFIREFolder;
            end
        end
        
        function result = getGABORFolder(params)
            if strcmp(params.OS,'WIN') == 1
                result = params.WIN.GaborFolder;
            else
                result = params.OSX.GaborFolder;
            end
        end
        
        function result = getTestingDirectory(params)
             if strcmp(params.OS,'WIN') == 1
                result = strcat(params.WIN.DataSetsPath,params.TestingFolder,'/');
            else
                result = strcat(params.OSX.DataSetsPath,params.TestingFolder,'/');
            end
        end
        
        function result = getModelsDirectory(params)
            if strcmp(params.OS,'WIN') == 1
                result = params.WIN.ModelsDirectory;
            else
                result = params.OSX.ModelsDirectory;
            end
        end
        %%
        
        %% Misc Utilities
        % Simple function which emits a beep when called
        function Signal()
            % Taken from http://www.h6.dion.ne.jp/~fff/old/technique/auditory/matlab.html#tone
            try
                cf = 2000;                  % carrier frequency (Hz)
                sf = 22050;                 % sample frequency (Hz)
                d = 0.05;                    % duration (s)
                n = sf * d;                 % number of samples
                s = (1:n) / sf;             % sound data preparation
                s = sin(2 * pi * cf * s);   % sinusoidal modulation
                sound(s, sf);               % sound presentation
                pause(d + 0.5);             % waiting for sound end
            catch err
                error(err.identifier);
            end
        end
        %%
    end
end