module GCTools

using DataStructures

const maxstacksize = 100

gccount( gc ) = gc.malloc + gc.realloc + gc.poolalloc + gc.bigalloc
gctic() = gccount( Base.gc_num() )

mutable struct Counter
    counts::OrderedDict{Symbol,Int}
    stack::Vector{Symbol}
    n::Int
end

Counter() = Counter( OrderedDict{Symbol,Int}(), fill( Symbol(), maxstacksize ), 1 )

const counter = Counter()

function reset()
    counter.counts = OrderedDict{Symbol,Int}()
    counter.stack = fill( Symbol(), maxstacksize )
    counter.n = 1
end

function push!( s::Symbol )
    count = gctic()
    if counter.n > 1
        counter.counts[counter.stack[counter.n-1]] += count
    end
    counter.stack[counter.n] = s
    counter.counts[s] = get( counter.counts, s, 0 ) - count
    counter.n += 1
end

function pop!()
    counter.n -= 1
    count = gctic()
    counter.counts[counter.stack[counter.n]] += count
    if counter.n > 1
        counter.counts[counter.stack[counter.n-1]] -= count
    end
    return counter.stack[counter.n]
end

function replace!( s::Symbol )
    if counter.n > 1
        last = pop!()
    end
    push!( s )
    return last
end

function print()
    for i = (counter.n-1):-1:1
        counter.counts[counter.stack[i]] += gctic()
    end
    for (k,v) in counter.counts
        println( "Count for $k: $v" )
    end
end    

end # module
