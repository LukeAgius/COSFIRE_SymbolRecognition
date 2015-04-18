function operator = configureCOSFIRE(prototypePattern,keypoint)

% Configure a COSFIRE operator for the pattern around the given keypoint in
% featureImage
%
% VERSION 01/07/2012
% CREATED BY: George Azzopardi and Nicolai Petkov, University of Groningen,
%             Johann Bernoulli Institute for Mathematics and Computer Science, Intelligent Systems
%
% If you use this script please cite the following paper:
%   George Azzopardi and Nicolai Petkov, "Trainable COSFIRE filters for
%   keypoint detection and pattern recognition", IEEE Transactions on Pattern 
%   Analysis and Machine Intelligence, 2012, DOI: 10.1109/TPAMI.2012.106

params = Parameters;

if strcmp(params.inputfilter.name,'Gabor')
    % Get responses of a Bank of Gabor filters
    input = getGaborResponse(prototypePattern,params.inputfilter.Gabor,params.inputfilter.Gabor.lambdalist,params.inputfilter.Gabor.thetalist);
end

%Suppress the responses that are lower than a given threshold t1 from the maximum response
input(input < params.COSFIRE.t1*max(input(:))) = 0;    

operator.tuples = getCOSFIRETuples(input,keypoint,params);    
operator.params = params;

function tuples = getCOSFIRETuples(input,keypoint,params)

tuples = [];
[sz(1) sz(2) sz(3) sz(4)] = size(input);
maxrho = max(params.COSFIRE.rholist);
supportRadius = ceil(maxrho + (params.COSFIRE.sigma0 + (params.COSFIRE.alpha*maxrho))*3);

% Enlarge the input area
biginput = zeros(sz(1) + (2*supportRadius),sz(2) + (2*supportRadius),sz(3),sz(4));
biginput(supportRadius+1:end-supportRadius,supportRadius+1:end-supportRadius,:,:) = input;
keypoint = keypoint + supportRadius;
biginput(biginput < params.COSFIRE.t2*max(biginput(:))) = 0;

% Superimpose the responses of the input filters
maxInput = max(reshape(biginput,sz(1)+(2*supportRadius),sz(2)+(2*supportRadius),prod(sz(3:end))),[],3);

% For every concentric circle extract the information about the dominant
% orientations of the contours. Characterize every such contour with a
% 4-tuple (lambda, theta, rho, phi)
for r = 1:length(params.COSFIRE.rholist)  
    tuple = getTuples(biginput, maxInput,keypoint,params.COSFIRE.rholist(r),params);
    tuples = [tuples [tuple.param1;tuple.param2;repmat(params.COSFIRE.rholist(r),1,length(tuple.phi));tuple.phi]];
end

function tuple = getTuples(input,maxInput,keypoint,rho,params)

if rho == 0
    if strcmp(params.inputfilter.name,'Gabor')
        centreResponses = reshape(input(keypoint(1),keypoint(2),:),length(params.inputfilter.Gabor.thetalist),length(params.inputfilter.Gabor.lambdalist))';
        [thetaMax, lambdaIndex] = max(centreResponses,[],1);
        thetaIndex = find(thetaMax);
        tuple.param1 = params.inputfilter.Gabor.lambdalist(lambdaIndex(thetaIndex));
        tuple.param2 = params.inputfilter.Gabor.thetalist(thetaIndex);        
    end
    tuple.phi = zeros(1,length(tuple.param2));        
elseif rho > 0
    tuple.param1 = [];
    tuple.param2 = [];
    tuple.phi    = [];
        
    philist = (1:360) * pi / 180;
    respAlongCircle = maxInput(sub2ind(size(maxInput),round(keypoint(1) - rho*sin(philist)),round(keypoint(2) + rho*cos(philist))));
       
    if length(unique(respAlongCircle)) == 1
        % The input along the circle of the given radius rho is constant      
        return;
    end
    
    BW = bwlabel(imregionalmax(respAlongCircle));
    npeaks = max(BW(:));
    peaks = zeros(1,npeaks);
    for i = 1:npeaks
        peaks(i) = floor(mean(find(BW == i)));
    end    
    
    peaklist = zeros(1,length(philist));
    peaklist(peaks) = respAlongCircle(peaks);
    [peaklist peaklocs] = findpeaks(peaklist,'minpeakdistance',round(params.COSFIRE.eta*180/pi));
    [phivalues uidx] = unique(mod(philist(peaklocs),2*pi));  
    if isempty(phivalues)              
        return;
    end
    if phivalues(1)+(2*pi) - phivalues(end) < params.COSFIRE.eta
        if peaklist(uidx(1)) <= peaklist(uidx(end))
            phivalues(1) = [];
        else
            phivalues(end) = [];
        end
    end
    [x y] = pol2cart(phivalues,rho);    
    for i = 1:length(phivalues)
        if strcmp(params.inputfilter.name,'Gabor')
            responses = reshape(input(keypoint(1)-round(y(i)),keypoint(2)+round(x(i)),:),length(params.inputfilter.Gabor.thetalist),length(params.inputfilter.Gabor.lambdalist))';        
            [thetaMax, lambdaIndex] = max(responses,[],1);
            thetaIndex = find(thetaMax);
            tuple.param1 = [tuple.param1 params.inputfilter.Gabor.lambdalist(lambdaIndex(thetaIndex))];
            tuple.param2 = [tuple.param2 params.inputfilter.Gabor.thetalist(thetaIndex)];
            tuple.phi    = [tuple.phi repmat(phivalues(i),1,length(thetaIndex))];
        end
    end    
end