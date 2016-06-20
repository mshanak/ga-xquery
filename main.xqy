xquery version "1.0-ml";

import module namespace ga='http://www.ppu.edu/ga' at 'ga.xqy';
declare namespace xdmp = "http://marklogic.com/xdmp";



declare function local:fitness($goal,$population)
{
  let $result:=for $indivisual at $j in $population/indivisual
 
		   let $r:= for $gene at $i in $indivisual/chromosomes/gene
		    	return if($gene!=$goal/chromosomes/gene[$i])
		    	then(1)
		    	else()

		let $f:=count($r)
	    return <indivisual>{$indivisual/chromosomes}<fitness>{$f}</fitness></indivisual>
	
   return  <population>{$result}</population>
  
};



let $population_size:=20
let $indivisual_size:=20
let $elite:=3
let $gene_values:=(0,1,2,3,4)


(: for testing:)
let $goal := for $j in 1 to 1
    let $indivisual:=for $i in 1 to $indivisual_size
            return <gene>1</gene>

    return <indivisual><chromosomes>{$indivisual}</chromosomes></indivisual>
    
(: END for testing:)








(: main area :)
let $fitnessfunction := xdmp:function(xs:QName("local:fitness"))
let $result := ga:start($population_size,$indivisual_size,$fitnessfunction,$goal,$gene_values)

		

 return

       <GA>   
 		<result>{$result}</result>
 	  

        </GA>
 