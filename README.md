Fantasy Baseball Lineups Optimization Code
======================

This is the code for constructing a portfolio of lineups for DraftKings baseball contests
with a top heavy payoff structure.  This code is based on 
the paper [Picking Winners Using Integer Programming](http://arxiv.org/pdf/1604.01455v2.pdf) by [David Hunter](http://orc.scripts.mit.edu/people/student.php?name=dshunter), [Juan Pablo Vielma](http://www.mit.edu/~jvielma/), and [Tauhid Zaman](http://zlisto.scripts.mit.edu/home/). Below are details on the required software, and instructions on how to run different variations of the code. 

## Required Software 
- [Julia](http://julialang.org/)
- [GLPK](https://www.gnu.org/software/glpk/)
- [JuMP](https://github.com/JuliaOpt/JuMP.jl)
- [DataFrames.jl](https://github.com/JuliaStats/DataFrames.jl)
- [GLPKMathProgInterface.jl](https://github.com/JuliaOpt/GLPKMathProgInterface.jl)

To start off, you should download Julia from the corresponding site above. Then, open Julia and run the following commands 
```julia
julia> Pkg.add("JuMP")
julia> Pkg.add("DataFrames")
julia> Pkg.add("GLPKMathProgInterface")
julia> Pkg.add("MathProgBase")
```

As we noted in the paper, [GLPK](https://www.gnu.org/software/glpk/) and [Cbc](https://projects.coin-or.org/Cbc) are both open-source solvers. This code uses GLPK because we found that it was slightly faster in practice for the formulations considered. For those that want to build more sophisticated models, they can buy [Gurobi](http://www.gurobi.com/). Please consult the [JuMP homepage](https://github.com/JuliaOpt/JuMP.jl) for details on how to use different solvers. JuMP makes it easy to change between a number of open-source and commercial solvers. 



## Downloading the Code 

You can download the code and the example csv files by calling 

```
$ git clone https://github.com/zlisto/dailyfantasybaseball
```

Alternatively, you can download the zip file from above. 



## Running the Code
Open the file ```optimize_multiple_lineups_baseball.jl```. By default the code will create 150 lineups with a maximum overlap of 
6 players between each lineup, and a stack of 5 consecutive batters. 
To change this, see lines 13, 16, and 19 in the file. For instance, if you want to create 10 lineups with a 
maximum overlap of 4 players, and a stack of 3 consecutive batters you change lines 13, 16, and 19 to the following 

```
num_lineups = 10
num_overlap = 4
stack_size = 3
```


Lastly, you can change the ```path_pitchers```, ```path_hitters```, and ```path_to_output``` variables 
defined on line 25, 26, and 29 respectively, to the name of the corresponding files for the pitcher and hitter projections
and the output lineups.

Good luck!

DK Mafia
