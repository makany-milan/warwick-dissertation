* estimate fixed effects
* Guimarães, P., Portugal, P., 2010A Simple Feasible Procedure to fit Models with High-dimensional Fixed EffectsThe Stata Journal 10, 628–649https://doi.org/10.1177/1536867X1101000406

* instead try
* felsdvreg

gen y = waif

felsdvreg y if female == 1, ivar(author_id) jvar(aff_inst_id) xb(none) res(none2) mover(mover) mnum(moves_n) pobs(none3) group(group) peff(fe1_fels_female) feff(fe2_fels_female) feffse(fe2_se_fels_female) cons
felsdvreg y if female == 0, ivar(author_id) jvar(aff_inst_id) xb(none) res(none2) mover(mover) mnum(moves_n) pobs(none3) group(group) peff(fe1_fels_female) feff(fe2_fels_female) feffse(fe2_se_fels_female) cons

err
* felsdvreg and zigzag seem to be converging to the same values while twfe is off by a large margin

* fe1: individual fixed effects: author_id
* fe2: department fixed effects: aff_inst_id

capture drop y temp fe1 fe2

generate double temp=0
generate double fe1=0

generate double fe2=0



local rss1=0
local dif=1
local i=0

* demean variables

while abs(`dif')>epsdouble() {
	quietly {
		regress y fe1 fe2
		local rss2=`rss1'
		local rss1=e(rss)
		local dif=`rss2'-`rss1'
		capture drop res
		predict double res, res
		replace temp=res+_b[fe1]*fe1, nopromote
		capture drop fe1
		egen double fe1=mean(temp), by(author_id)
		replace temp=res+_b[fe2]*fe2, nopromote
		capture drop fe2
		egen double fe2=mean(temp), by(aff_inst_id)
		local i=`i'+1
		
		if mod(`i', 10) == 0{
				noisily: di "Iteration `i' - dif = `dif'"
			}
		}
	}
}

display "Total Number of Iterations --> `i'"