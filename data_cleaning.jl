#this file has a bunch of data cleaning functions
using DataFrames



################################################################################################################
function clean_order(Order)  #cleans up the batting order so that it is a number
    Order_clean =[];
    for order in Order
        if ~(typeof(order)==DataArrays.NAtype)
            if isa(parse(order), Number) 
                order_clean = parse(order); 
            else
                order_clean = 0;
            end
        else
            order_clean=0;
        end
        Order_clean = [Order_clean;order_clean];
    end
    return Order_clean;
end

################################################################################################################
# read_player_data loads information from hitters and pitchesr files into a single table
function read_player_data(path_hitters,path_pitchers)
    pitchers = readtable(path_pitchers);
    hitters = readtable(path_hitters);


    function clean_str(str)
        if str[1]=='@'
            return str[2:end];
        else
            return  str;
        end
    end

    Team = [pitchers[:Team]; hitters[:Team]];
    Opp=[pitchers[:Opp]; hitters[:Opp]];
    Game = [];
    for i = 1:size(Team)[1]
        t1 = clean_str(Team[i]);
        t2 = clean_str( Opp[i]);
        t = sort([t1,t2]);
        Game = [Game;string(t[1]," ",t[2])];
    end

    function clean_num(x)
        if isnan(x)
            return 0;
        else
            return  x;
        end
    end


    p=map(clean_num, [pitchers[:Proj_FP]; hitters[:Proj_FP]]);
    proj_val=map(clean_num, [pitchers[:Proj_Val]; hitters[:Proj_Val]]);
    a=map(clean_num,[pitchers[:Actual_FP]; hitters[:Actual_FP]]);
    players = DataFrame(Player_Name = [pitchers[:Player_Name]; hitters[:Player_Name]],
                        Team = [pitchers[:Team]; hitters[:Team]],
                        Opp=[pitchers[:Opp] ;hitters[:Opp]],
                        Game = Game,
                        Pos=[pitchers[:Pos] ;hitters[:Pos]],
                        Salary=[pitchers[:Salary] ;hitters[:Salary]],
                        Proj_FP=p,
                        Proj_Val = proj_val,
                        Actual_FP=a,
                        Batting_Order_Confirmed_ = [round(Int,zeros(size(pitchers)[1])); clean_order(hitters[:Batting_Order_Confirmed_])]
                        );

    return players;
end

###################################################################################################
# Output CSV file to upload to DraftKings
function createOutputcsvFromTracer(tracer, players, P, C, oneB, twoB, threeB,SS,OF,path_to_output)
    # should be in format P P C 1B 2B 3B SS OF OF OF
    num_lineups = size(tracer)[2]
    num_players =size(tracer)[1]
    P_index = 1
    C_index = 3
    oneB_index = 4
    twoB_index = 5
    threeB_index = 6
    SS_index = 7
    OF_index = 8
    GrowingLineupMatrix = "P,P,C,1B,2B,3B,SS,OF,OF,OF\n"
    for j = 1:num_lineups
        
        lineup = ["" "" "" "" "" "" "" "" "" ""]
        for i =1:num_players
            if tracer[i,j] == 1
                #println("\tlineup ", j," player ", i, ":", string(players[i,:Player_Name])," ",string(players[i,:Pos]))
            
                if P[i]==1  
                    # if player i's position is P
                    if lineup[P_index]==""
                        lineup[P_index] = string(players[i,:Player_Name])
                    elseif lineup[P_index+1] ==""
                        lineup[P_index+1] = string(players[i,:Player_Name])
                    else
                        println(string("error in lineup",j,"player",i))
                    end

                elseif C[i]==1
                    if lineup[C_index]==""
                        lineup[C_index] = string(players[i,:Player_Name])
                    else
                        println(string("error in lineup",j,"player",i))
                    end
                elseif oneB[i]==1
                    if lineup[oneB_index]==""
                        lineup[oneB_index] = string(players[i,:Player_Name])
                    else
                        println(string("error in lineup",j,"player",i))
                    end
                elseif twoB[i]==1
                    
                    if lineup[twoB_index]==""
                        lineup[twoB_index] = string(players[i,:Player_Name])
                    else
                        println(string("error in lineup",j,"player",i))
                    end
                elseif threeB[i]==1
                    
                    if lineup[threeB_index]==""
                        lineup[threeB_index] = string(players[i,:Player_Name])
                    else
                        println(string("error in lineup",j,"player",i))
                    end
                elseif SS[i]==1
                    
                    if lineup[SS_index]==""
                        lineup[SS_index] = string(players[i,:Player_Name])
                    else
                        println(string("error in lineup",j,"player",i))
                    end
                else
                    if OF[i] != 1
                        println(string("error in lineup",j,"player",i))
                    end

                    if lineup[OF_index]==""
                        lineup[OF_index] = string(players[i,:Player_Name])
                    elseif lineup[OF_index+1] ==""
                        lineup[OF_index+1] = string(players[i,:Player_Name])
                    elseif lineup[OF_index+2] ==""
                        lineup[OF_index+2] = string(players[i,:Player_Name])
                    else
                        println(string("error in lineup",j,"player",i))
                    end

                end
                
            end
        end
       
        
        LineupOK = true
        lineupRow =""
        for name in lineup
            lineupRow = string(lineupRow, name, ",")
        end
        
        lineupRow = chop(lineupRow)  #remove extra comma
        lineupRow = string(lineupRow,"\n")
        GrowingLineupMatrix = string(GrowingLineupMatrix,lineupRow) 
    end
    

    outfile = open(path_to_output, "w")
    write(outfile, GrowingLineupMatrix)
    close(outfile)
    


end

###########################################################################################
#####################################################################################################################
#####################################################################################################################
#this function will create the lineups and save them to a file
function create_lineups(num_lineups, num_overlap, stack_size,formulation, path_pitchers,path_hitters,  path_to_output)
    #=
    num_lineups is an integer that is the number of lineups
    num_overlap is an integer that gives the overlap between each lineup
    stack_size = number of players in the stack
    path_pitchers,path_hitters is a string that gives the path to the hitters and pitchers projections file
    formulation is the type of formulation you would like to use (for instance one_lineup_Type_1, one_lineup_Type_2, etc.)
    path_to_output is a string where the final csv file with your lineups will be
    =#
    
    println("loading projection data")
    players =read_player_data(path_hitters,path_pitchers);

    
    # Number of players
    num_players = size(players)[1]
    println(num_players," players playing tonight")


    # Create team indicators from the information in the players file
    teams = unique(players[:Team])
    num_teams = size(teams)[1]
    println(num_teams," teams playing tonight")

    # Create team indicators from the information in the players file
    games = unique(players[:Game])
    num_games = size(games)[1]
    println(num_games," games playing tonight")


    # arrays that store the information on which players are which position
    P = Array(Int64, 0);
    B1 = Array(Int64, 0);
    B2 =Array(Int64, 0);
    B3 =Array(Int64, 0);
    C =Array(Int64, 0);
    SS=Array(Int64, 0);
    OF=Array(Int64, 0);
    RP=Array(Int64, 0);


    #=
    Process the position information in the skaters file to populate the position and order
    #arrays  with the corresponding correct information
    =#
    for i =1:num_players
        pos = players[i,:Pos];
        #print(players[i,:Player_Name]," ",pos,"\n") 
        if contains(pos,"SP") 
            P=vcat(P,fill(1,1))
            B1=vcat(B1,fill(0,1))
            B2=vcat(B2,fill(0,1))
            B3=vcat(B3,fill(0,1))
            C=vcat(C,fill(0,1))
            SS=vcat(SS,fill(0,1))
            OF=vcat(OF,fill(0,1))
            RP=vcat(RP,fill(0,1))


        elseif contains(pos,"RP") 
            P=vcat(P,fill(0,1))
            RP=vcat(RP,fill(1,1))
            B1=vcat(B1,fill(0,1))
            B2=vcat(B2,fill(0,1))
            B3=vcat(B3,fill(0,1))
            C=vcat(C,fill(0,1))
            SS=vcat(SS,fill(0,1))
            OF=vcat(OF,fill(0,1))
            
        elseif contains(pos,"1B") 
            P=vcat(P,fill(0,1))
            B1=vcat(B1,fill(1,1))
            B2=vcat(B2,fill(0,1))
            B3=vcat(B3,fill(0,1))
            C=vcat(C,fill(0,1))
            SS=vcat(SS,fill(0,1))
            OF=vcat(OF,fill(0,1))
            RP=vcat(RP,fill(0,1))

        elseif contains(pos,"2B") 
            P=vcat(P,fill(0,1))
            B1=vcat(B1,fill(0,1))
            B2=vcat(B2,fill(1,1))
            B3=vcat(B3,fill(0,1))
            C=vcat(C,fill(0,1))
            SS=vcat(SS,fill(0,1))
            OF=vcat(OF,fill(0,1))
            RP=vcat(RP,fill(0,1))

        elseif contains(pos,"3B") 
            P=vcat(P,fill(0,1))
            B1=vcat(B1,fill(0,1))
            B2=vcat(B2,fill(0,1))
            B3=vcat(B3,fill(1,1))
            C=vcat(C,fill(0,1))
            SS=vcat(SS,fill(0,1))
            OF=vcat(OF,fill(0,1))
            RP=vcat(RP,fill(0,1))

        elseif contains(pos,"C") 
            P=vcat(P,fill(0,1))
            B1=vcat(B1,fill(0,1))
            B2=vcat(B2,fill(0,1))
            B3=vcat(B3,fill(0,1))
            C=vcat(C,fill(1,1))
            SS=vcat(SS,fill(0,1))
            OF=vcat(OF,fill(0,1))
            RP=vcat(RP,fill(0,1))

        elseif contains(pos,"SS") 
            P=vcat(P,fill(0,1))
            B1=vcat(B1,fill(0,1))
            B2=vcat(B2,fill(0,1))
            B3=vcat(B3,fill(0,1))
            C=vcat(C,fill(0,1))
            SS=vcat(SS,fill(1,1))
            OF=vcat(OF,fill(0,1))
            RP=vcat(RP,fill(0,1))

        elseif contains(pos,"OF") 
            P=vcat(P,fill(0,1))
            B1=vcat(B1,fill(0,1))
            B2=vcat(B2,fill(0,1))
            B3=vcat(B3,fill(0,1))
            C=vcat(C,fill(0,1))
            SS=vcat(SS,fill(0,1))
            OF=vcat(OF,fill(1,1))
            RP=vcat(RP,fill(0,1))

        else
            println("\t",players[i,:Player_Name]," has no position\n")

        end
    end


    #GAMES:   players_games stores information on which game each player is on
    player_info = zeros(Int, num_games)

    # Populate player_info with the corresponding information
    for j=1:num_games
        if players[1, :Game] == games[j]
            player_info[j] =1
        end
    end
    players_games = player_info'

    for i=2:num_players
        player_info = zeros(Int, num_games)
        for j=1:num_games
            if players[i, :Game] == games[j]
                player_info[j] =1
            end
        end
        players_games = vcat(players_games, player_info')
    end

    #TEAMS:   players_teams stores information on which team each player is on
    player_info = zeros(Int, num_teams)

    # Populate player_info with the corresponding information
    for j=1:size(teams)[1]
        if players[1, :Team] == teams[j]
            player_info[j] =1
        end
    end
    players_teams = player_info'

    for i=2:num_players
        player_info = zeros(Int, num_teams)
        for j=1:size(teams)[1]
            if players[i, :Team] == teams[j]
                player_info[j] =1
            end
        end
        players_teams = vcat(players_teams, player_info')
    end

    #OPPONENT TEAM players_opp stores information on which team each player is opposing
    player_info = zeros(Int, num_teams)

    # Populate player_info with the corresponding information
    for j=1:num_teams
        if players[1, :Opp]=='@'
            opp = players[1, :Opp][2:end]
        else
            opp = players[1, :Opp]
        end
        
        if opp == teams[j]
            player_info[j] =1
        end
    end
    players_opp = player_info'

    for i=2:num_players
        player_info = zeros(Int, num_teams)
        for j=1:size(teams)[1]
            if players[i, :Opp]=='@'
                opp = players[i, :Opp][2:end]
            else
                opp = players[i, :Opp]
            end
            if opp == teams[j]
                player_info[j] =1
            end
        end
        players_opp = vcat(players_opp, player_info')
    end

    #STACK players_stacks stores information on which team each player is on
    num_stacks = 9;  #number of stacks
    
    #make matrix for 1st stacking (stacking_order[1])
    player_info = zeros(Int,num_stacks);

    # Populate player_info with the corresponding information, start with the first player to initiate the array
    for j=1:num_stacks
        if players[1,:Batting_Order_Confirmed_] == j
            stack_ind = circshift(collect(1:9),stack_order-j)[1:stack_order[1]];  #index of the stacks this batting order belongs to.  
            #For ex., batting order 1, stacking order 3, will belong to (8,9,1),(9,1,2) and (1,2,3)
            for k in stack_ind
                player_info[k]=1;
            end
        end
    end
    players_stacks = player_info';

    #now update the stack matrix of players 2 to num_players
    for i=2:num_players
        player_info = zeros(Int,num_stacks);
        for j=1:num_stacks
            if players[i,:Batting_Order_Confirmed_] == j
                stack_ind = circshift(collect(1:9),num_stacks-j)[1:num_stacks];  #index of the stacks this batting order belongs to.  
                #For ex., batting order 1, stacking order 3, will belong to (8,9,1),(9,1,2) and (1,2,3)
                for k in stack_ind
                    player_info[k]=1;
                end
            end
        end
        players_stacks = vcat(players_stacks, player_info');
    end

    ###########################################################################
    #my formulation is:  formulation(players, old_lineups, num_overlap, stack_size,P,B1,B2,B3,C,SS,OF, players_teams, players_opp, players_games,players_stacks)

    # Lineups using formulation as the stacking type
    println("Calculating lineup 1 of ", num_lineups)
           #baseball_formulation(players, old_lineups, num_overlap, P,B1,B2,B3,C,SS,OF, players_teams, players_opp, players_games,players_stacks, stack_size)
    old_lineups =  hcat(zeros(Int, num_players), zeros(Int, num_players))
    the_lineup  = formulation(players, old_lineups, num_overlap,stack_size, 
                              P,B1,B2,B3,C,SS,OF, players_teams, players_opp, players_games,players_stacks)

    println("Calculating lineup 2 of ", num_lineups)
    old_lineups =hcat(the_lineup, zeros(Int, num_players))
    the_lineup2 = formulation(players, old_lineups, num_overlap,stack_size, 
                              P,B1,B2,B3,C,SS,OF, players_teams, players_opp, players_games,players_stacks)

    old_lineups = hcat(the_lineup, the_lineup2)
    for i=1:(num_lineups-2)
        println("Calculating lineup ", i+2, " of ", num_lineups)
        try
            thelineup = formulation(players, old_lineups, num_overlap,stack_size, 
                              P,B1,B2,B3,C,SS,OF, players_teams, players_opp, players_games,players_stacks)
            old_lineups = hcat(old_lineups,thelineup)
        catch
            print("some optimization error")
            break
        end
    end
    
    createOutputcsvFromTracer(old_lineups, players, P, C, B1, B2, B3,SS,OF,path_to_output)

end
###########################################################################################
#save file with lineups and projected points
function lineup_points_proj(path_lineups,path_hitters,path_pitchers,path_output)
    players = read_player_data(path_hitters,path_pitchers)
    lineups = readtable(path_lineups)
    num_lineups = size(lineups)[1]
    num_spots = size(lineups)[2]
    num_players = size(players)[1]
    GrowingLineupMatrix = "P,P,C,1B,2B,3B,SS,OF,OF,OF,Proj_pts\n"
    for i = 1:num_lineups
        lineup_pts = 0
        for j = 1:num_spots
            name = lineups[i,j]
            for k = 1:num_players
                if string(players[k,1])==string(name)
                    lineup_pts  = lineup_pts+players[k,:Proj_FP]
                end
            end
            GrowingLineupMatrix = string(GrowingLineupMatrix,name,",")
        end
        GrowingLineupMatrix = string(GrowingLineupMatrix, string(lineup_pts), "\n")
    end
    outfile = open(path_output, "w")
    write(outfile, GrowingLineupMatrix)
    close(outfile)

end

###########################################################################################
#save file with lineups and projected and actual points
function lineup_points_actual(path_lineups,path_hitters,path_pitchers,path_output)
    players = read_player_data(path_hitters,path_pitchers)
    lineups = readtable(path_lineups)
    num_lineups = size(lineups)[1]
    num_spots = size(lineups)[2]
    num_players = size(players)[1]
    GrowingLineupMatrix = "P,P,C,1B,2B,3B,SS,OF,OF,OF,Proj_pts,Actual_pts\n"
    for i = 1:num_lineups
        lineup_pts_proj = 0
        lineup_pts_actual=0
        for j = 1:num_spots
            name = lineups[i,j]
            for k = 1:num_players
                if string(players[k,1])==string(name)
                    lineup_pts_proj  = lineup_pts_proj + players[i,:Proj_FP]
                    lineup_pts_actual  = lineup_pts_actual + players[k,:Actual_FP]

                end
            end
            GrowingLineupMatrix = string(GrowingLineupMatrix,name,",")
        end
        GrowingLineupMatrix = string(GrowingLineupMatrix, string(lineup_pts_proj),",",string(lineup_pts_actual), "\n")
    end
    outfile = open(path_output, "w")
    write(outfile, GrowingLineupMatrix)
    close(outfile)

end

