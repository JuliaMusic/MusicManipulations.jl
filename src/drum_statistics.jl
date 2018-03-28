export drum_statistics, drum_statistics_noplot, drumgraph

"""
    drum_statistics(not::Notes, pit = ALLPITCHES_TD50, extratext = "")

Plot an histogram of the velocities for all instruments played. Additionally some statistical quantities are calculated.
"""
function drum_statistics(not::Notes, pit = ALLPITCHES_TD50, extratext = "")
    for pitch in pit
        #decide wheter the current instrument has 127 or 159 as maximum velocity
        if pitch in DIGITAL
            maxvel = 159
        else
            maxvel = 127
        end
        #collect velocities as individuals and for histogram
        histdata = zeros(maxvel+1)
        data = UInt8[]
        for note in not
            if note.value == pitch
                histdata[note.velocity]+=1
                push!(data,note.velocity)
            end
        end
        #display an analisis if instrument was played
        if length(data)!=0
            fig = figure()
            fig[:set_size_inches](6,4.5)
            ax1 = fig[:add_subplot](211)
            ax2 = fig[:add_subplot](212)

            ax1[:bar](range(0,maxvel+1),histdata)
            ax1[:set_title](TD50_MAP[pitch])
            ax1[:set_xlabel]("velocity")
            ax1[:set_xlim](0,maxvel)
            ax1[:set_ylabel]("amount")

            ax2[:set_axis_off]()
            ax2[:text](0,0.5,"
            minimum: $(minimum(data))         maximum: $(maximum(data))
            mean value: $(mean(data))        median: $(median(data))
            individual velocities: $(length(unique(data)))         total hits:$(length(data))        $(maxvel) hits: $(count(i->(i==maxvel),data))
            $(extratext)")
            fig[:tight_layout]()
        end
    end
end


"""
    drum_statistics_noplot(not::Notes, pit = ALLPITCHES_TD50)

Write statistical information about the velocities of each played instrument to the console. A warning message is displayed, if more than 2.5% of the velocities are clipped.
"""
function drum_statistics_noplot(not::Notes, pit = ALLPITCHES_TD50)
    for pitch in pit
        #collect velocities
        data = UInt8[]
        for note in not
            if note.value == pitch
                push!(data,note.velocity)
            end
        end
        #decide wheter the current instrument has 127 or 159 as maximum velocity
        if pitch in DIGITAL
            maxvel = 159
        else
            maxvel = 127
        end
        #display an analisis if instrument was played
        if length(data) != 0
            #count how often the maximum velocity was played to give extra clipping warning
            clipwarn = count(i->(i==maxvel),data)
            println("$(TD50_MAP[pitch]):    minimum: $(minimum(data))         maximum: $(maximum(data))
            mean value: $(mean(data))        median: $(median(data))
            individual velocities: $(length(unique(data)))         total hits:$(length(data))       $(maxvel) hits: $(clipwarn)")
            if clipwarn*40 > length(data)
                println("MORE THAN 2.5% OF MAXIMUM VELOCITY\n")
            else
                print("\n")
            end
        end
    end
end

"""
    drumgraph(notes::Notes)

Plot a graph of played notes vs. ticks sorted by instrument.
"""
function drumgraph(notes::Notes)
    #initialize figure
    f = figure()
    get_current_fig_manager()[:window][:state]("zoomed")
    ax = axes()
    #collect values of interest
    positions = Int[]
    values = UInt8[]
    velos = UInt8[]
    for note in notes
        push!(positions,note.position)
        push!(values,note.value)
        push!(velos,note.velocity)
    end
    #shift pitches to number of instrument
    values = map(i->GRAPHMAP_TD50[i],values)
    #plot the whole thing
    scatter(positions,values,s=2,c=velos,cmap="copper_r")
    colorbar()
    ax[:set_ylim](-0.5,19.5)
    ax[:set_yticks](range(0,21))
    ax[:set_yticklabels](GRAPHTICKS_TD50)
end
