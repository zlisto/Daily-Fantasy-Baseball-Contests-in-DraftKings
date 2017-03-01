# This code solves for multiple baseball lineups

include("data_cleaning.jl")
include("baseball_formulations.jl")  #this code has all the different formualations


################################################################################################################
################################################################################################################
################################################################################################################

#INPUT PARAMS
folder = ""  #folder where the player projections are - this folder is named by the date of the contest

# num_lineups is the total number of lineups
num_lineups = 4; 

# num_overlap is the maximum overlap of players between the lineups 
num_overlap = 6

#number of hitters in the stack (number of consecutive hitters in the hitting order)
stack_size = 5; 

#FORMULATION:  formulation is the type of formulation that you would like to use. 
formulation = baseball_formulation

#path to the csv file with the players information (pitchers and hitters);
path_pitchers = string(folder,"2016-08-12 dailyfantasynerd_pitchers.csv") 
path_hitters = string(folder,"2016-08-12 dailyfantasynerd_hitters.csv");

# path_to_output is a string  that gives the path to the csv file that will give the outputted results
path_to_output= string(folder,"baseball_", string(formulation), "_stacksize_", stack_size,"_overlap_", num_overlap,"_lineups_", num_lineups,".csv"); 

# path_to_output_proj is a string  that gives the path to the csv file that will give the outputted results with projected lineup points
path_to_output_proj = string(folder,"proj_baseball_", string(formulation), "_stacksize_", stack_size,"_overlap_", num_overlap,"_lineups_", num_lineups,".csv"); 

# path_to_output_actual is a string  that gives the path to the csv file that will give the outputted results with projected and actual lineup points
path_to_output_actual = string(folder,"actual_baseball_", string(formulation), "_stacksize_", stack_size,"_overlap_", num_overlap,"_lineups_", num_lineups,".csv"); 


#########################################################################
# Running the code
println("Calculating DraftKings baseball linueps.\n ", num_lineups, " lineups\n","Formulation  ",formulation,
"\nOverlap = ", num_overlap,"\nStack size = ", stack_size)

tic()
create_lineups(num_lineups, num_overlap, stack_size,formulation, path_pitchers,path_hitters,  path_to_output);
telapsed = toq();

println("Calculated DraftKings baseball lineups.\n", num_lineups, " lineups\n","Stack type ",formulation,
"\nOverlap = ", num_overlap[1],"\n" )

println("Took ", telapsed/60.0, " minutes to calculate ", num_lineups, " lineups")

println("Saving data to file ",path_to_output,"\nDK Mafia 4 life")

#save the projected and actual points for the lineups
lineup_points_proj(path_to_output,path_hitters,path_pitchers,path_to_output_proj);
lineup_points_actual(path_to_output,path_hitters,path_pitchers,path_to_output_actual);

