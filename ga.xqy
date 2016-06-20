xquery version "1.0-ml";
module namespace ga='http://www.ppu.edu/ga';
declare namespace xdmp = "http://marklogic.com/xdmp";
declare namespace map = "http://marklogic.com/xdmp/map";
 
 




declare function ga:start($population_size as xs:integer , $indivisual_size as xs:integer,$fitness_function,$goal,$gene_values) {



    let $t:=50
    let $mutation_percent:=10
    let $crossover_percent :=40
    let $elite:=3

    (: initilization :)
        let $population := ga:init($population_size,$indivisual_size,$gene_values)
        let $population:= xdmp:apply($fitness_function, $goal,$population)
        let $population:=ga:orderByFitness($population)


(:loop for t generations :)
 let $population :=  for $i in 1 to $t
  return if($population/indivisual[1]/fitness = 0)
            then(<found>$i</found> )
    else(
        let $population:=ga:crossover($population,$crossover_percent,$elite  ) 
        let $population:=ga:mutate($population,$mutation_percent,$elite)
        let $population:= xdmp:apply($fitness_function, $goal,$population)
        let $population:=ga:orderByFitness($population)
        return $population/indivisual[1]/fitness
    )


return <bestfitness>{$population}</bestfitness>
};



declare function ga:init($numberOfSolutions as xs:integer , $solutionLength as xs:integer,$gene_values) {

let $population  :=()
let $indivisual := ()
 

let $population := for $j in 1 to $numberOfSolutions
    let $indivisual:=for $i in 1 to $solutionLength
            let $random:=xdmp:random(count($gene_values)-1)+1
            let $v := $gene_values[$random]
            return <gene>{$v}</gene>

    return <indivisual><chromosomes>{$indivisual}</chromosomes><fitness>9999</fitness></indivisual>
    
return <population>{$population}</population>

};



declare function ga:mutate($population,$mutation_percent as xs:integer,$elite as xs:integer )  {

let $population:=$population
let $new_population:=()
let $population_size:=count($population/indivisual)
let $indivisual_size:=count($population/indivisual[1]/chromosomes/gene)

let $selected_mutation_indivisuals:=map:map()
let $mutate_indivisual_count:=fn:round($mutation_percent div 100 * $population_size)
 
let $s:=for $i in 1 to $mutate_indivisual_count

    let $mutation_index:= xdmp:random($indivisual_size)
    let $mutation_indivisual:= $elite+ xdmp:random($population_size)
    return if(map:contains($selected_mutation_indivisuals,concat("",$mutation_indivisual)))
           then(
                    let $i:=10
                     return "duplicate"
                )
                    
            else(
                    let $k:=map:put($selected_mutation_indivisuals,concat("",$mutation_indivisual),$mutation_index)
                    return $k
                 )


let $new_population := for $indivisual at $j in $population/indivisual

    return if (map:contains($selected_mutation_indivisuals,concat("",$j)))
    then(


    let $new_indivisual:=for $gene at $i in $indivisual/chromosomes/gene
            return if($i=map:get($selected_mutation_indivisuals,concat("",$j)))
                then(
                     if($gene=1)
                        then <gene>{$i}</gene>
                        else <gene>{$i}</gene>
                    )
                    
                 else(
                      $gene)
    
         return <indivisual><chromosomes>{$new_indivisual}</chromosomes><fitness>{$indivisual/fitness}</fitness></indivisual>

    )
    else 
         $indivisual


return <population>{$new_population}</population>

};


declare function ga:orderByFitness($population )  {
 let $new_population :=  for $indivisual in $population/indivisual
    order by xs:integer($indivisual/fitness) ascending
    return $indivisual

  return <population>{$new_population}</population>
  
};


 
declare function ga:crossover($population,$crossover_percent as xs:integer,$elite as xs:integer )  {

let $population:=$population
let $new_population:=()
let $population_size:=count($population/indivisual)
let $indivisual_size:=count($population/indivisual[1]/chromosomes/gene)

let $crossover_indivisual_count:=fn:round($crossover_percent div 100 * $population_size  )
let $crossover_index:= xdmp:random($indivisual_size)

let $newchildren_tmp:=for $i in 1 to $crossover_indivisual_count 
        let $parent1:=$population/indivisual[$i]
        let $parent2:=$population/indivisual[$i+1]

        let $child1_p1:=for $j in 1 to $crossover_index
                        return $parent1/chromosomes/gene[$j]
        let $child2_p1:=for $j in 1 to $crossover_index
                        return $parent2/chromosomes/gene[$j]       
        let $child2_p2:=for $j in $crossover_index to $indivisual_size
                        return $parent1/chromosomes/gene[$j]
        let $child1_p2:=for $j in $crossover_index to $indivisual_size
                        return $parent2/chromosomes/gene[$j] 
    return <newchildren><indivisual><chromosomes>{$child1_p1}{$child1_p2}</chromosomes><fitness>9999</fitness></indivisual><indivisual><chromosomes>{$child2_p1}{$child2_p2}</chromosomes><fitness></fitness></indivisual></newchildren>
 
    let $newchildren:=for $child in $newchildren_tmp
                    return $child/indivisual

    let $newchildrenIndex:= $population_size - $crossover_indivisual_count 
    
 (:)   let $result:= for $indivisual at $i in $population/indivisual
                    return if($i >= $newchildrenIndex)
                        then( $newchildren[$population_size - $i +1])
                        else($indivisual)
 :)
    let $result:= for $i in 1 to $population_size
                    return if($i >= $newchildrenIndex)
                        then( $newchildren[$population_size - $i +1] )
                        else($population/indivisual[$i])

 
return <population>{$result}</population>
};
  



