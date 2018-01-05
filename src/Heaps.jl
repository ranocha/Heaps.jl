module Heaps

# Various heap implementation

###########################################################
#
#   Heap interface specification
#
#   Each heap is associated with a handle type (H), and
#   a value type v.
#
#   Here, the value type must be comparable, and a handle
#   is an object through which one can refer to a specific
#   node of the heap and thus update its value.
#
#   Each heap type must implement all of the following
#   functions. Here, let h be a heap, i be a handle, and
#   v be a value.
#
#   - length(h)           returns the number of elements
#
#   - isempty(h)          returns whether the heap is
#                         empty
#
#   - push!(h, v)         add a value to the heap
#
#   - sizehint!(h)         set size hint to a heap
#
#   - top(h)              return the top value of a heap
#
#   - pop!(h)             removes the top value, and
#                         returns it
#
#  For mutable heaps, it should also support
#
#   - push!(h, v)         adds a value to the heap and
#                         returns a handle to v
#
#   - update!(h, i, v)    updates the value of an element
#                         (referred to by the handle i)
#
#   - top_with_handle(h)  return the top value of a heap
#                         and its handle
#
#
###########################################################

using Compat: uninitialized, Nothing, Cvoid, AbstractDict



import Base: <, <=, ==, length, isempty, start, next, done, delete!,
                 show, dump, empty!, getindex, setindex!, get, get!,
                 in, haskey, keys, merge, copy, cat,
                 push!, pop!, shift!, unshift!, insert!,
                 union!, delete!, similar, sizehint!,
                 isequal, hash,
                 map, reverse,
                 first, last, eltype, getkey, values, sum,
                 merge, merge!, lt, Ordering, ForwardOrdering, Forward,
                 ReverseOrdering, Reverse, Lt,
                 isless,
                 union, intersect, symdiff, setdiff, issubset,
                 find, searchsortedfirst, searchsortedlast, endof, in

export BinaryHeap, binary_minheap, binary_maxheap, nlargest, nsmallest
export MutableBinaryHeap, mutable_binary_minheap, mutable_binary_maxheap
export heapify!, heapify, heappop!, heappush!, isheap

# HT: handle type
# VT: value type

abstract type AbstractHeap{VT} end

abstract type AbstractMutableHeap{VT,HT} <: AbstractHeap{VT} end

# comparer

struct LessThan
end

struct GreaterThan
end

compare(c::LessThan, x, y) = x < y
compare(c::GreaterThan, x, y) = x > y

# generic functions

function extract_all!(h::AbstractHeap{VT}) where VT
    n = length(h)
    r = Vector{VT}(uninitialized, n)
    for i = 1 : n
        r[i] = pop!(h)
    end
    r
end

function extract_all_rev!(h::AbstractHeap{VT}) where VT
    n = length(h)
    r = Vector{VT}(uninitialized, n)
    for i = 1 : n
        r[n + 1 - i] = pop!(h)
    end
    r
end

# Array functions using heaps

function nextreme(comp::Comp, n::Int, arr::AbstractVector{T}) where {T, Comp}
    if n <= 0
        return T[] # sort(arr)[1:n] returns [] for n <= 0
    elseif n >= length(arr)
        return sort(arr, lt = (x, y) -> compare(comp, y, x))
    end

    buffer = BinaryHeap{T,Comp}(comp)

    for i = 1 : n
        @inbounds xi = arr[i]
        push!(buffer, xi)
    end

    for i = n + 1 : length(arr)
        @inbounds xi = arr[i]
        if compare(comp, top(buffer), xi)
            # This could use a pushpop method
            pop!(buffer)
            push!(buffer, xi)
        end
    end

    return extract_all_rev!(buffer)
end

@doc """
Returns the `n` largest elements of `arr`.

Equivalent to `sort(arr, lt = >)[1:min(n, end)]`
""" ->
function nlargest(n::Int, arr::AbstractVector{T}) where T
    return nextreme(LessThan(), n, arr)
end

@doc """
Returns the `n` smallest elements of `arr`.

Equivalent to `sort(arr, lt = <)[1:min(n, end)]`
""" ->
function nsmallest(n::Int, arr::AbstractVector{T}) where T
    return nextreme(GreaterThan(), n, arr)
end

# implementations
include("heaps/binary_heap.jl")
include("heaps/mutable_binary_heap.jl")
include("heaps/arrays_as_heaps.jl")

include("priorityqueue.jl")

end # module
