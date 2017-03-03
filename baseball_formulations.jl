#This code implements the formulations for  baseball lineups

# To install DataFrames, simply run Pkg.add("DataFrames")
using DataFrames

# To install MathProgBase, simply run Pkg.add("MathProgBase")
using MathProgBase
# Once again, to install run Pkg.add("JuMP")
using JuMP


#=
GLPK is an open-source solver.  For those that want to build
very sophisticated models, they can buy Gurobi. To install GLPKMathProgInterface, simply run
Pkg.add("GLPKMathProgInterface")
=#
using GLPKMathProgInterface

#uncomment this line only if you installed Gurobi, which costs money :(), but is super fast :)
using Gurobi  




#####################################################################################################################
#####################################################################################################################
# This is a function that creates one lineup using the  Stacking Type 3 formulation
# No pitcher opposite batter
# Batters with consecutive batting order
#only keep 4th order and earlier batters, cuz they make more points
function baseball_formulation(players, old_lineups, num_overlap,stack_size, P,B1,B2,B3,C,SS,OF, players_teams, players_opp, players_games,players_stacks)
    

    #################################################################################################
    #define the model formulation which will be solved using GLPK
    m = Model(solver=GLPKSolverMIP())

    #uncomment this line only if you are using Gurobi, which costs money :(), but is super fast :)
    m = Model(solver=GurobiSolver(OutputFlag=0))
   
	#number of players playing today
    num_players = size(players)[1]
    
    #number of games today
    games = unique(players[:Game])
    num_games = size(games)[1]
    
    #number of teams playing today
    teams = unique(players[:Team])
    num_teams = size(teams)[1]

    #number of stacks per team (this is 9)
    num_stacks = 9;  
    



    # Variable for players in lineup.
    @defVar(m, players_lineup[i=1:num_players], Bin)
    
    #OBJECTIVE
    @setObjective(m, Max, sum{players[i,:Proj_FP]*players_lineup[i], i=1:num_players})


    #NUMBER OF PLAYERS: 10 players constraint
    @addConstraint(m, sum{players_lineup[i], i=1:num_players} == 10)
    
    #SALARY: Financial Constraint - salary less than $50,000
    @addConstraint(m, sum{players[i,:Salary]*players_lineup[i], i=1:num_players}<= 50000)

    #POSITION
    #  2 P constraint
    @addConstraint(m, sum{P[i]*players_lineup[i], i=1:num_players}==2)
    # one B1 constraint
    @addConstraint(m, sum{B1[i]*players_lineup[i], i=1:num_players}==1)
    # one B2 constraint
    @addConstraint(m, sum{B2[i]*players_lineup[i], i=1:num_players}==1)
    # one B3 constraint
    @addConstraint(m, sum{B3[i]*players_lineup[i], i=1:num_players}==1)
    # one C constraint
    @addConstraint(m, sum{C[i]*players_lineup[i], i=1:num_players}==1)
    # one SS constraint
    @addConstraint(m, sum{SS[i]*players_lineup[i], i=1:num_players}==1)
    # 3 OF constraint
    @addConstraint(m, sum{OF[i]*players_lineup[i], i=1:num_players}==3)
  
   
  
    #GAMES: at least 2 different games for the 10 players constraints
    #variable for each game used in lineup, equals 1 if game used
    @defVar(m, used_game[i=1:num_games], Bin)
    #constraint satisfied by each game
    @addConstraint(m, constr[i=1:num_games], used_game[i] <= sum{players_games[t, i]*players_lineup[t], t=1:num_players})
    #constraint makes sure at least 2 used_game variables equal 1
    @addConstraint(m, sum{used_game[i], i=1:num_games} >= 2)


    #HITTERES at most 5 hitters from one team constraint
    @addConstraint(m, constr[i=1:num_teams], sum{players_teams[t, i]*(1-P[t])*players_lineup[t], t=1:num_players}<=5)
    

    #OVERLAP Constraint
    @addConstraint(m, constr[i=1:size(old_lineups)[2]], sum{old_lineups[j,i]*players_lineup[j], j=1:num_players} <= num_overlap)

 
    #NO PITCHER VS BATTER no pitcher vs batter constraint
    @addConstraint(m, hitter_pitcher[g=1:num_teams], 
                   8*sum{P[k]*players_lineup[k]*players_teams[k,g],k=1:num_players} + 
                    sum{(1-P[k])*players_lineup[k]*players_opp[k,g], k=1:num_players}<=8)


    #STACK: at least stack_size hitters from at least 1 team, consecutive hitting order
 	#define a variable for each stack on each team.  This variable =1 if the stack on the team is used
    @defVar(m, used_stack_batters[i=1:num_teams,j=1:num_stacks], Bin)
    
    #constraint for each stack, used or not
    @addConstraint(m, constraint_stack[i=1:num_teams,j=1:num_stacks], stack_size*used_stack_batters[i,j] <= 
                   sum{players_teams[t, i]*players_stacks[t, j]*(1-P[t])*players_lineup[t], t=1:num_players})  
    
    #make sure at least one stack is used
    @addConstraint(m, sum{used_stack_batters[i,j], i=1:num_teams,j=1:num_stacks} >= 1)  
	
	


	########################################################################################################
    # Solve the integer programming problem  
    tic()
    status = solve(m);
   

    # Puts the output of one lineup into a format that will be used later
    if status==:Optimal
        players_lineup_copy = Array(Int64, 0)
        for i=1:num_players
            if getValue(players_lineup[i]) >= 0.9 && getValue(players_lineup[i]) <= 1.1
                players_lineup_copy = vcat(players_lineup_copy, fill(1,1))
            else
                players_lineup_copy = vcat(players_lineup_copy, fill(0,1))
            end
        end

        return(players_lineup_copy)
    end
end