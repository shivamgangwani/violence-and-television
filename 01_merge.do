// Merging .do file


/* Basic setup & config */
clear
set more off  
cd "/Users/shgwani/Desktop/IHDS_STATA"


// 1. Open primary dataset (Eligible women dataset)
use 02_raw/36151-0003-Data, clear

// 2. Merge with household data
merge m:1 STATEID DISTID PSUID HHID HHSPLITID using 02_raw/36151-0002-Data

// 3. Check the match results
tabulate _merge


// 4. Remove unmatched data. 
// Some households have no eligible women, so not all rows from household data will find match in women data
// We keep only the matched rows

drop if _merge != 3
drop _merge

// 5. Match count from _merge tabulate
count


// 6. All OK, save data
capture erase 03_merged/merged.dta
save 03_merged/merged.dta
