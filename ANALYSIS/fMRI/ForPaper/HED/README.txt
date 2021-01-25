ReadMe HEDONIC


GLM-between: Model with no first level covariates, we added covariates at the second level.
*FOR DAVID: FORMER HED-01: TO REMOVE*

GLM-between-control: Model with absolute change as a control variable at the first level, we added covariates at the second level.
*FOR DAVID: THIS IS NEW*

GLM-within: Model for odor (neutral + reward) modulated by intensity and liking as 1st level modulators &  durations = 1 & mean centered & orth =0
->  2 contrast odor*lik + odor*int
*FOR DAVID: FORMER HED-15: TO REMOVE*

GLM-within-control: Model only for odor with molecule (empty air entered as separate onsets) with control regressor changing for the better and absolute change (on the odorant only)
->  4 contrasts odor*int odor*lik (odor*ch odor*chAbs)

*FOR DAVID: FORMER HED-28: TO REMOVE*
