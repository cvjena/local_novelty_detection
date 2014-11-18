function demo_local_novelty_detection
% function demo_local_novelty_detection
% 
% BRIEF
%       A brief demo showing how to use the local novelty detection code.
% 
%       The UCI USPS digits dataset serves as playground.
%       All steps from loading data, over pre-processing, parameter settings,
%       learning, testing to final evaluations are explained in detail.
% 
% INPUT
%       nothing
% 
% OUTPUT
%       nothing
% 
% author: Paul Bodesheim, Alexander Freytag
% date  : 18-11-2014 ( dd-mm-yyyy )

    %% (1) load data for evaluation
    
    % specify destination of USPS training data
    % needs to be adapted to your system!

    s_fn_features_train = '/home/user/data/UCI/USPS/optdigits.tra';    
    assert( exist(s_fn_features_train, 'file') == 2, ...
            sprintf('%s not available. You can download the USPS digits dataset available at https://archive.ics.uci.edu/ml/machine-learning-databases/optdigits/ ', s_fn_features_train) ...
          );        

    
    % specify destination of USPS test data
    % needs to be adapted to your system!
    s_fn_features_test = '/home/user/data/UCI/USPS/optdigits.tes';    
    
    % load USPS train data   
    
    A            = load( s_fn_features_train );
    dataTrain    = A(:,1:64);
    labelsTrain  = A(:,65);
    
    %simulate novelty detection scenario: only 3 classes are known
    knownClasses = [1,2,3];
    idxKnown     = ismember ( labelsTrain, knownClasses);
    dataTrain    = dataTrain ( idxKnown , : );
    labelsTrain  = labelsTrain ( idxKnown );
    clear A;

    % load USPS test data
    A          = load( s_fn_features_test );
    dataTest   = A(:,1:64);
    labelsTest = A(:,65);
    clear A;
  
    %% (2) training (pre-computations), and parameter specification
    %  2.1) compute covariance matrix for training data
    covFct   = {'covSEisoU'};    
    % check that covariance/kernel function is available on your system
    % suggestion: possible add gpml toolbox
    % addpath(genpath( '<myPathToGPMLToolbox> ) );
    assert( exist(covFct{:}, 'file') == 2, ...
            sprintf('%s not available. You could include gpml-toolbox available at http://www.gaussianprocess.org/gpml/code/matlab/doc/ ', covFct{:} ) ...
          );    
    covParam = [3.0];
    K        = feval( covFct{:},covParam, dataTrain);
    
    %  2.2) specify settings
    
    % set names of methods you want to apply
    % note: scripts for learning novelty detection models need to be named
    % "learn_<MyModel>.m"
    
    % novelty detection model for one-class-scenarios
    methods{1} = 'oneClassNovelty_knfst';
    % novelty detection model for multi-class-scenarios
    methods{2} = 'multiClassNovelty_knfst';
    
    % check that methods are available in your system
    for i=1:length(methods)
        s_fctName = sprintf('learn_%s.m', methods{i});
        assert( exist(s_fctName, 'file') == 2, ...
                sprintf('%s not available, aborting...', s_fctName ) ...
              );
        %note: if an error occured, you need to add the folder of the 
        %      specified novelty detection methods to your matlab search path 
        %        
        % suggestion: add KNFST folder
        % addpath(genpath( '<myPathToKNFST> ) );        
    end
    
    % set additional parameters, left empty here
    method_params{1} = {}; 
    method_params{2} = {};

    % of course you can specify another size of the neighborhood
    numNeighbors     = min ( 25, round(length(labelsTrain)/2) );  

    %  2.3) perform computations for "training"
    model            = learn_local_novelty_detection_model( K, labelsTrain, methods, method_params, numNeighbors );

    %% (3) use local learning for unseen data
    %  3.1) compute covariance matrix for test data
    Ks  = feval( covFct{:},covParam, dataTrain, dataTest);
    
    %  3.2) run local novelty detection on test data
    scores = test_local_novelty_detection_model( model, Ks );
    
    %% (4) evaluate local learning results
    figure;
    
    idxTestKnown        = ismember ( labelsTest, knownClasses );
    numKnownTestSamples = sum(idxTestKnown);
    idxTestKnown        = ismember ( labelsTest, knownClasses );
    
    % plot novelty scores for samples of known classes
    plot ( 1:numKnownTestSamples, scores(idxTestKnown), 'g');
    hold on;
    % plot novelty scores for samples of unknown classes
    % these guys should be HIGHER then those of known classes...
    plot ( (numKnownTestSamples+1):length(labelsTest), scores(~idxTestKnown),'b');

end