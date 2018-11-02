module GCTools

using DataStructures

gccount( gc ) = gc.malloc + gc.realloc + gc.poolalloc + gc.bigalloc
gctic() = gccount( Base.gc_num() )

mutable struct Counter
    counts::OrderedDict{Symbol,UInt}
    current::Union{Symbol,Nothing}
end

Counter() = Counter( OrderedDict{Symbol,UInt}(), nothing )

const counter = Counter()

function reset()
    counter.counts = OrderedDict{Symbol,UInt}()
    counter.current = nothing
end

function checkpoint( s::Symbol )
    count = gctic()
    if counter.current != nothing
        counter.counts[counter.current] += count
    end
    counter.current = s
    counter.counts[s] = get( counter.counts, s, 0 ) - count
end

function checkpoint()
    counter.counts[counter.current] += gctic()
    counter.current = nothing
end

function print()
    if counter.current != nothing
        counter.counts[counter.current] += gctic()
    end
    for (k,v) in counter.counts
        println( "Count for $k: $v" )
    end
end    

end # module
