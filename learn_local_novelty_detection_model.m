% Learning method for local novelty detection according to the work:
%
% Paul Bodesheim and Alexander Freytag and Erik Rodner and Joachim Denzler:
% "Local Novelty Detection in Multi-class Recognition Problems".
% Proceedings of the IEEE Winter Conference on Applications of Computer Vision (WACV), 2015.
%
% Please cite that paper if you are using this code!
%
%
% function model = learn_local_novelty_detection_model( K, labels, methods, method_params, numNeighbors )
%
% Calculate a model for local novelty detection.
% In fact we only store parameters, since learning is done on-the-fly in the test phase and specific for each test sample
%
% INPUT: 
%   K -- (n x n) kernel matrix containing similarities of n training samples
%   labels -- (n x 1) column vector containing (multi-class) labels of n training samples
%   methods -- a cell array of size 2 containing strings for the methods that will be used in local learning
%              methods{1} -- string of the one-class method, if methods{1} = 'oneClassNovelty_knfst' then there must exist functions named
%                            learn_oneClassNovelty_knfst and test_oneClassNovelty_knfst
%              methods{2} -- string of the one-class method, if methods{2} = 'multiClassNovelty_knfst' then there must exist functions named
%                            learn_multiClassNovelty_knfst and test_multiClassNovelty_knfst
%              NOTE: Following this convention, you can easily plug-in other novelty detection methods. 
%                    KNFST methods are included in this package as an example
%   method_params -- a two-dimensional cell array specifying the parameters for the one-class method in method_params{1} 
%                    and the parameters for the multi-class method in method_params{2}
%                    NOTE: for a method without parameters, such as KNFST, both are empty: method_params{1} = {}; method_params{2} = {};
%                    Otherwise: store the paramters of your method (depending on its order in the function call) in 
%                               method_params{1}{1}, method_params{1}{2}, etc. (See also test_local_novelty_detection_model for the usage of method_params)
%   numNeighbors -- size of the neighborhood (parameter k in the paper)
%
% OUTPUT:
%   model -- model struct used in test_local_novelty_detection_model
%
% (LGPL) copyright by Paul Bodesheim and Alexander Freytag and Erik Rodner and Joachim Denzler
%
function model = learn_local_novelty_detection_model( K, labels, methods, method_params, numNeighbors )

  %%% ==========================
  %%% check the input parameters
  %%% ==========================

  if (numNeighbors ~= round(numNeighbors)) || numNeighbors < 2
  
    error('input "numNeighbors" has to be an integer larger than 1');

  end     

  if numNeighbors >= length(labels)
   
    warning('input "numNeighbors" is larger than or equal to the number of samples, I will use all samples now');
   
  end

  if ~iscell(method_params) || length(method_params) ~= 2

    error('input "method_params" has to be cell arrays of size 2');

  end

  if ~iscell(methods) || length(methods) ~= 2 || ~ischar(methods{1}) || ~ischar(methods{2}) 

    error('input "methods" has to be cell arrays of size 2 containing strings');

  elseif exist(sprintf('learn_%s',methods{1}),'file') ~= 2 || exist(sprintf('test_%s',methods{1}),'file') ~= 2

    error('You specified methods{1} = %s, but there is either no method "learn_%s" or no method "test_%s" in your current Matlab search path',methods{1},methods{1},methods{1});

  elseif exist(sprintf('learn_%s',methods{2}),'file') ~= 2 || exist(sprintf('test_%s',methods{2}),'file') ~= 2

    error('You specified methods{2} = %s, but there is either no method "learn_%s" or no method "test_%s" in your current Matlab search path',methods{2},methods{2},methods{2});

  end

  if size(K,1) ~= size(K,2)

    error('input "K" has to be a square matrix');

  end

  if length(labels) ~= size(K,1)

    error('input "labels" should be a vector of size equal to the number of rows/columns of input "K"');

  end
  
  %%% ==========================================================================================
  %%% store everything in the model structure, we perform learning on-the-fly in the test method
  %%% ==========================================================================================

  model.K = K;
  model.labels = labels;
  model.classes = unique(labels);
  model.methods = methods;
  model.methods_params = method_params;
  model.numNeighbors = numNeighbors;
  
end

