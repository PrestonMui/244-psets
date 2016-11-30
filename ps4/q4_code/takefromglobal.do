capture program drop takefromglobal
program define takefromglobal
  *See: http://www.econometricsbysimulation.com/2012/07/remove-subset-from-global-stata.html
  * First define a local called temp to hold the initial values of the global
  local temp ${`1'}
 
  * Empty the global
  global `1'
 
  * Loop through each of the old values
  foreach v of local temp {
   
 * Start counting at 0
    local i = 0

 * Create a local that indicates that this value should be skipped (initially assume no skipping)
 local skip = 0
 
 * Loop through all of the user specified inputs `0'
    foreach vv in `0' {
 
 * We will skip the first one since we know it is just the global specified
      local i = `i' + 1
  
   * If we are past the first input in the local and one our values to exclude matches the value in the global skip that value
   if `i' > 1 & "`vv'"=="`v'" local skip = 1
    }
 
 * If the current value is not to be skipped then add it to the new global list
 if `skip' == 0 global `1' ${`1'} `v'
  }
end
