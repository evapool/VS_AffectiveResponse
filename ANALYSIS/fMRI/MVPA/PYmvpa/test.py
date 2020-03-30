def warn(*args, **kwargs):
    pass
import warnings
warnings.warn = warn

from mvpa2.suite import *

vector_file = '/Users/davidmunoz/REWOD/DERIVATIVES/ANALYSIS/MVPA/hedonic/MVPA-04/sub-26/mvpa/svm_smell_nosmell_Perm.hdf5'
null_dist = h5load(vector_file)
dd = 0