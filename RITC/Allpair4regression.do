/*
Name: allpairs.do
Aim:  create all pairs dataset and compute some statititics
date: 28 sept
*input :basecell4regression
*/

///////////// Desciptives basecell///////////////////////////////////////////////////

clear all
cd "/Users/williamewane/Desktop/dossierbase"
*cd "C:\Users\wb535383\Desktop\construction_database_rwanda"
clear all
use  basecell4regression

/// create first price ddatabase (justb for fist seller0
keep product marketname_str month year price_dest1 longitude latitude market_uid origin1 price_origin1 dist_orign1

rename (marketname_str  price_dest1 longitude latitude market_uid origin1 price_origin1 dist_orign1) (marketnameA priceA longitudeA latitudeA market_uidA originA price_originA dist_originA)

save allpairA, replace



clear all
cd "/Users/williamewane/Desktop/dossierbase"
*cd "C:\Users\wb535383\Desktop\construction_database_rwanda"
*clear all
use  basecell4regression

/// create second price ddatabase (justb for fist seller0
keep product marketname_str month year price_dest1 longitude latitude market_uid origin1 price_origin1 dist_orign1

rename (marketname_str  price_dest1 longitude latitude market_uid origin1 price_origin1 dist_orign1) (marketnameB priceB longitudeB latitudeB market_uidB originB price_originB dist_originB)

save allpairB, replace


/// form all pairs

clear all
cd "/Users/williamewane/Desktop/dossierbase"
use allpairA
joinby product month year using allpairB

// compute distance between pairs of markets



 *********** road distance*******
 geodist latitudeA longitudeA latitudeB longitudeB , gen (roaddistanceAB) miles

 
 
***** great-circle distance********
 
  geodist latitudeA  longitudeA  latitudeB longitudeB, gen (gc_distanceAB) miles
  
  
// compute travel time


 *georoute, hereid (aBMDFIF5UHs3IeM4RfDL) herecode(1vdOZgMkzFFEjPdyc6d3uQ) startxy (latitude1 longitude1) endxy(latitude2 longitude2) time(traveltime)
 
 *drop georoute_diagnostic
 
 
 // some ajustements
 
 drop if marketnameA==marketnameB


//declarer le panel

egen mdate= group(year month)
egen panelid=group(product market_uidA market_uidB)
xtset mdate panelid


// generer pricegap

**************For all pairs************************

gen pricegap_allpairs=priceA-priceB
gen abspricegap_allpairs= abs(pricegap_allpairs)
gen lroaddistance = ln(roaddistance)

*************for trading pairs*******************

gen pricegap_trading= priceA-price_originA
gen ldist_originA = ln(dist_originA)
gen abspricegap_tradingpairs= abs(pricegap_trading)
save allpair4regression,replace

// estimates relation between price and distance

*allpairs
lpoly abspricegap_allpairs lroaddistance if(lroaddistance>=0 & lroaddistance <=5), bw(0.5) nosc ci saving(graph1)
*trading pairs
lpoly abspricegap_tradingpairs ldist_originA if( ldist_originA>=0 &  ldist_originA <=5), bw(0.5) nosc ci saving(graph2)

graph combine graph1.gph graph2.gph

* comparison trading and all pairs

twoway (lpolyci abspricegap_allpairs lroaddistance if (lroaddistance>0& lroaddistance<3 & abspricegap_allpairs!=.)) (lpolyci abspricegap_tradingpairs ldist_originA if (ldist_originA>0& ldist_originA<3 & abspricegap_tradingpairs!=.))



// statistics all pairs

***first seller

clear all
use  allpair4regression

tabstat abspricegap_allpairs roaddistance priceA , stat(mean, sd, N)

*** second seller

clear all
use  allpair4regression2

tabstat abspricegap_allpairs roaddistance priceA  , stat(mean, sd, N)






