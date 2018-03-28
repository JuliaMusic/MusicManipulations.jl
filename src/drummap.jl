
# Map the pitches of midinotes to Instruments of Roland TD-50
drummap = Dict{UInt8,String}(
    0x16=>"Hihat Shaft (closed)",
    0x1a=>"Hihat Shaft",
    0x24=>"Kick",
    0x26=>"Snare",
    0x28=>"Snare Rimshot",
    0x2a=>"Hihat Tip (closed)",
    0x2b=>"Tom 3",
    0x2c=>"Hihat Foot Close",
    0x2d=>"Tom 2",
    0x2e=>"Hihat Tip",
    0x2f=>"Tom 2 Rimshot",
    0x30=>"Tom 1",
    0x32=>"Tom 1 Rimshot",
    0x33=>"Ride Tip",
    0x35=>"Ride Bell",
    0x37=>"Cymbal 1",
    0x39=>"Cymbal 2",
    0x3a=>"Tom 3 Rimshot",
    0x3b=>"Ride Shaft")

# All posible pitches in an Array
allpitches = collect(keys(drummap))

# Map the pitches to numbers for plotting in a graph
graphmap = Dict{UInt8,UInt8}(
    0x16=>8,
    0x1a=>5,
    0x24=>1,
    0x26=>2,
    0x28=>3,
    0x2a=>7,
    0x2b=>16,
    0x2c=>6,
    0x2d=>14,
    0x2e=>4,
    0x2f=>15,
    0x30=>12,
    0x32=>13,
    0x33=>9,
    0x35=>11,
    0x37=>18,
    0x39=>19,
    0x3a=>17,
    0x3b=>10)

# names of Instruments (order according to graphmap) for updating ticks in graph
graphticks =    ["Kick","Snare","Snare Rimshot","Hihat Tip",
                 "Hihat Shaft","Hihat Foot Close","Hihat Tip (closed)",
                 "Hihat Shaft (closed)","Ride Tip","Ride Shaft",
                 "Ride Bell","Tom 1","Tom 1 Rimshot","Tom 2",
                 "Tom 2 Rimshot","Tom 3","Tom 3 Rimshot","Cymbal 1","Cymbal 2"]
