function params = Parameters
% VERSION 26/05/2012
% CREATED BY: George Azzopardi and Nicolai Petkov, University of Groningen,
%             Johann Bernoulli Institute for Mathematics and Computer Science, Intelligent Systems
%
% SystemConfig returns a structure of the parameters required by the
% COSFIRE operator

% The radii list of concentric circles

% Original
% ==============================
% BATCH 1 params.COSFIRE.rholist        = [0 4 9 15 22];

% Experiment 1
% ==============================
% BATCH 1  params.COSFIRE.rholist       = [0 4 9 15 22 30 39 49 60 72 85 99 114 130 147 165];
% BATCH 2  params.COSFIRE.rholist       = [0 5 10 15 20 25 30 35 40 45 50 55 60 65 70 75 85 80 85 90 95 100 105 110 115,120 125 130 135 140 145 150 155 160 165];

% Experiment 2 & 3
% ==============================
% params.COSFIRE.rholist                 = [0 4 15 30 49 72 99 130 165];

% Experiment 4 & 5
% ==============================
% params.COSFIRE.rholist                 = [4 30 72 130 165];

% Experiment 6
% ==============================
% FIRST BATCH params.COSFIRE.rholist                 = [4 30 72 118 165];
% SECOND BATCH params.COSFIRE.rholist                 = [4 30 72 120 165];

% Experiment 7,8,9
% ==============================
%  params.COSFIRE.rholist                 = [60 120];

% Experiment 10
% ==============================
%params.COSFIRE.rholist                 = [40 140];
params.COSFIRE.rholist                = [0 10 25 45];

% Minimum distance between dominant contours lying on the same concentric circle
params.COSFIRE.eta                    = pi/8;

% Threshold parameter used to suppress the input filters responses that are less than a
% fraction t1 of the maximum
params.COSFIRE.t1                     = 0; %0.2;

% Threshold parameter used to select the channels of input filters that
% produce a response larger than a fraction t2 of the maximum
params.COSFIRE.t2                     = 0.75;

% Parameters of the Gaussian function used to blur the input filter
% responses. sigma = sigma0 + alpha*rho_i
params.COSFIRE.sigma0                 = 5; %10; %0.67;
params.COSFIRE.alpha                  = 0.1;

% mintupleweight is the weight assigned to the peripherial contour parts
params.COSFIRE.mintupleweight         = 0.5;
params.COSFIRE.outputfunction         = 'weightedgeometricmean';
params.COSFIRE.blurringfunction       = 'max'; %max or sum

% Weights are computed from a 1D Gaussian function. weightingsigma is the
% standard deviation of this Guassian function
params.COSFIRE.weightingsigma         = sqrt(-max(params.COSFIRE.rholist)^2/(2*log(params.COSFIRE.mintupleweight)));

% Threshold parameter used to suppress the responses of the COSFIRE filters
% that are less than a fraction t3 of the maximum response.
params.COSFIRE.t3                     = 0;

% Parameters of some geometric invariances
params.invariance.rotation.psilist    = 0; %0:pi/8:(2*pi)-(pi/8); %(0:22.5:359)*pi/180;
params.invariance.scale.upsilonlist   = 1; %2.^(-0.5:0.5:0.5);
params.invariance.reflection          = 0; % Reflection invariance about the y-axis. 0 = do not use, 1 = use.
% when using rotation, put reflection = 1

% Minimum distance allowed between detected keypoints. If the distance
% between any two pairs of detected keypoints is less than
% params.distance.mindistance then we keep only the stronger one.
params.detection.mindistance          = 8;

% Parameters of the input filter. Here we use symmetric Gabor filters.
% Gabor filters are, however, not intrinsic to the method and any other
% filters can be used.
params.inputfilter.name                    = 'Gabor';
params.inputfilter.Gabor.thetalist          = 0:pi/8:pi-(pi/8);
params.inputfilter.Gabor.lambdalist         = [4*sqrt(2),8,8*sqrt(2)];
params.inputfilter.Gabor.phaseoffset        = pi;
params.inputfilter.Gabor.halfwaverect       = 0;
params.inputfilter.Gabor.bandwidth          = 2;
params.inputfilter.Gabor.aspectratio        = 0.5;
params.inputfilter.Gabor.inhibition.method  = 1;
params.inputfilter.Gabor.inhibition.alpha   = 0;
params.inputfilter.Gabor.thinning           = 0;

if strcmp(params.inputfilter.name,'Gabor')
    params.inputfilter.symmetric = ismember(params.inputfilter.Gabor.phaseoffset,[0 pi]);
else 
    % Other input filter type
    params.inputfilter.symmetric = 1;
end