ReadMe HEDONIC


GLM-between: Model with no first level covariates, we added covariates at the second level.

GLM-between-control: Model with absolute change as a control variable at the first level, we added covariates at the second level.

GLM-within: Model for odor (neutral + reward) modulated by intensity and liking as 1st level modulators &  durations = 1 & mean centered & orth =0
->  2 contrast odor*lik + odor*int

GLM-within-control: Model only for odor with molecule (empty air entered as separate onsets) with control regressor changing for the better and absolute change (on the odorant only)
->  4 contrasts odor*int odor*lik (odor*ch odor*chAbs)

