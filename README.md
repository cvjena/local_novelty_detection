# Local Novelty Detection

## COPYRIGHT

This package contains Matlab source code to perform local novelty detection as described in:

*Paul Bodesheim and Alexander Freytag and Erik Rodner and Joachim Denzler:*   
**"Local Novelty Detection in Multi-class Recognition Problems".**   
Proceedings of the IEEE Winter Conference on Applications of Computer Vision (WACV), 2015.  

Please cite that paper if you are using this code!

(LGPL) copyright by Paul Bodesheim and Alexander Freytag and Erik Rodner and Joachim Denzler



## CONTENT

* `learn_local_novelty_detection_model.m`
* `test_local_novelty_detection_model.m`
* `demo_local_novelty_detection.m`
* `README.md`
* `License.txt`
* `code_knfst.zip`

## KNFST source code

We also included the source code from our paper:  
*Paul Bodesheim and Alexander Freytag and Erik Rodner and Michael Kemmler and Joachim Denzler:*   
**"Kernel Null Space Methods for Novelty Detection".**   
Proceedings of the IEEE Conference on Computer Vision and Pattern Recognition (CVPR), 2013.  
since we used KNFST in our local novelty detection experiments. Please check also the README.txt in the archive file `code_knfst.zip`.
A mirror with latest stable versions of KNFST is available at [https://github.com/cvjena/knfst](https://github.com/cvjena/knfst)
The following examples also use methods from `code_knfst.zip`

## USAGE

Use the method `learn_local_novelty_detection_model` to initialize the model structure and the method `test_local_novelty_detection_model` to compute novelty scores.

Please refer to the documentations in those methods for explanations of input and output variables.

Assuming you have already computed a kernel matrix "K", your label vector is called "labels", and kernel values between n training samples and m test samples stored in a matrix "Ks", then you can use the following (do not forget to unzip `code_knfst.zip` before!):

```
methods{1}       = 'oneClassNovelty_knfst';  
methods{2}       = 'multiClassNovelty_knfst';  
method_params{1} = {};  
method_params{2} = {};  
numNeighbors = round(length(labels)/2); % of course you can specify another size of the neighborhood  
model        = learn_local_novelty_detection_model( K, labels, methods, method_params, numNeighbors );  
scores       = test_local_novelty_detection_model( model, Ks );  
```

## DEMO PROGRAM


simply run the following script in Matlab:

`demo_local_novelty_detection`