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
```

As we noted in the paper, [GLPK](https://www.gnu.org/software/glpk/) and [Cbc](https://projects.coin-or.org/Cbc) are both open-source solvers. This code uses GLPK because we found that it was slightly faster in practice for the formulations considered. For those that want to build more sophisticated models, they can buy [Gurobi](http://www.gurobi.com/). Please consult the [JuMP homepage](https://github.com/JuliaOpt/JuMP.jl) for details on how to use different solvers. JuMP makes it easy to change between a number of open-source and commercial solvers. 



## Downloading the Code 

You can download the code and the example csv files by calling 

```
$ git clone https://github.com/zlisto/dailyfantasybaseball
```

Alternatively, you can download the zip file from above. 



## Running the Code
Open the file ```code_for_Github.jl```. By default the code will create 150 lineups with a maximum overlap of 
6 players between each lineup. 
To change this, see lines 26 and 29 in the file. For instance, if you want to create 10 lineups with a 
maximum overlap of 4 players, you change lines 26 and 29 to the following 

```
num_lineups = 10
num_overlap = 4
```

By default, the code creates the lineup using the formulation where you stack the lineup by putting 5 consecutive
batters from a single team and dont have pitchers opposing hitters. 



Lastly, you can change the ```path_skaters```, ```path_goalies```, and ```path_to_output``` variables 
defined on line 32, 35, and 38 respectively. For instance, if you place ```goalies.csv``` and ```skaters.csv``` 
in your home directory, and would like the lineps to be outputted to a file ```output.csv``` 
in your home directory, you would change the code to the following 

```
path_pitchers = "/users/home/skaters.csv"
path_hitters = "/users/home/goalies.csv"
path_to_output = "/users/home/output.csv"
```

where ```home``` above is changed to correspond with your computers home directory. 

Now that you have done this, you should be done. You should not need to change anything else in the file ```code_for_Github.jl```. 
Now you can build your own lineups.

We have made an attempt to describe the code in great detail, with the hope that you will use 
your expertise to build better formulations. Good luck!

DK Mafia
