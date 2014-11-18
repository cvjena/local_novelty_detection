% Testing method for local novelty detection according to the work:
%
% Paul Bodesheim and Alexander Freytag and Erik Rodner and Joachim Denzler:
% "Local Novelty Detection in Multi-class Recognition Problems".
% Proceedings of the IEEE Winter Conference on Applications of Computer Vision (WACV), 2015.
%
% Please cite that paper if you are using this code!
%
%
% function scores = test_local_novelty_detection_model( model, Ks )
%
% Calculate novelty scores following local novelty detection and using the model structure obtained from learn_local_novelty_detection_model.
% For each test sample, a novelty detection model is learned on-the-fly using its k nearest neighbors of the training set.
% Models are either one-class or multi-class models depending on the class distribution in the neighborhood
%
% INPUT:
%    model -- model obtained from learn_local_novelty_detection_model
%    Ks -- (n x m) kernel matrix containing similarities between n training samples and m test samples
%
% OUTPUT:
%    scores -- novelty scores for the m test samples obtained by exemplar-specific local novelty detection models
%
% (LGPL) copyright by Paul Bodesheim and Alexander Freytag and Erik Rodner and Joachim Denzler
%
function scores = test_local_novelty_detection_model( model, Ks )

  %%% get number of test samples
  n_test_samples = size(Ks,2); 

  %%% init scores
  scores = zeros(n_test_samples, 1); 

  %%% check size of Ks
  if size(Ks,1) ~= size(model.K,1)

    error('number of rows of input "Ks" must match number of rows of "model.K"');

  end
  
  %%% loop over test samples
  for t=1:n_test_samples
    
    %%% sort train samples according to the distance to the current test sample in the kernel feature space
    [~,sort_id] = sort(Ks(:,t),'descend');

    %%% get IDs of the nearest neighbors
    sort_id = sort_id(1:min(model.numNeighbors,length(model.labels)));
   
    %%% check whether all neighbors belong to the same class
    occ_setting = length(unique(model.labels(sort_id))) == 1;
    
    %%% check for OCC setting
    if occ_setting

      %%% ================================
      %%% One-class classification setting
      %%% ================================
     
      if ~isempty(model.methods_params{1})

        %%% learn a local one-class model with additional method parameters taking only the nearest neighbors into account
        local_model = feval(sprintf('learn_%s',model.methods{1}) , model.K( sort_id , sort_id ) , model.methods_params{1}{:} );
        
      else
       
        %%% learn a local one-class model without additional method parameters (such as KNFST) taking only the nearest neighbors into account
        local_model = feval(sprintf('learn_%s',model.methods{1}) , model.K( sort_id , sort_id ) );
        
      end
            
      %%% evaluate the local one-class model for the current test sample
      scores(t) = feval(sprintf('test_%s',model.methods{1}) , local_model , Ks( sort_id , t ) );
      
    else

      %%% =====================================
      %%% Multi-class novelty detection setting
      %%% =====================================

      if ~isempty(model.methods_params{2})
       
        %%% learn a local multi-class model with additional method parameters taking only the nearest neighbors into account
        local_model = feval(sprintf('learn_%s',model.methods{2}) ,model.K( sort_id , sort_id ) , model.labels(sort_id), model.methods_params{2}{:} );

      else
       
        %%% learn a local multi-class model without additional method parameters (such as KNFST) taking only the nearest neighbors into account
        local_model = feval(sprintf('learn_%s',model.methods{2}) ,model.K( sort_id , sort_id ) , model.labels(sort_id) );
        
      end
      
      %%% evaluate the local multi-class model for the current test sample
      scores(t) = feval(sprintf('test_%s',model.methods{2}) , local_model , Ks( sort_id , t ) );      
      
    end
       
  end
 
end

