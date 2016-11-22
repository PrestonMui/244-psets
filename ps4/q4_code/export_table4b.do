// This file exports the table produced in part (b) of pset4_q4.do
esttab mvreg_est using input/ps4_q4b.tex, ///
    unstack se replace nonum ///
    cells(b(star fmt(2)) se(par fmt(2))) ///
    eqlabels("1984" "1985" "1986" "1987" "1988" "1989" "1990") ///
    mlabels("Log of Arrests Made in", span  ///
                                      prefix(\multicolumn{@span}{c}{) ///
                                      suffix(})) ///
    starlevels(* 0.10 ** 0.05 *** 0.01) ///
    varlabels( _cons "Year Intercept" ///
        enacted_84 "Enacted in 1984" /// 
        enacted_85 "Enacted in 1985" /// 
        enacted_86 "Enacted in 1986" /// 
        enacted_87 "Enacted in 1987" /// 
        enacted_88 "Enacted in 1988" /// 
        enacted_89 "Enacted in 1989" /// 
        enacted_90 "Enacted in 1990")