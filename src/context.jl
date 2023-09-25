
struct Context
    data::Dict{DataType, Union{Nothing, Some}}

    function Context(names::Vector{DataType})
        new(Dict([name=>nothing for name in names]))
    end
end

Base.getindex(c::Context, k::DataType) = getindex(c.data, k)
function Base.setindex!(c::Context, v::Some{T}, k::Type{<:Artifact{T}}) where T
    if !haskey(c.data, k)
        error("Can't set unknown Artifact")
    end
    if !isnothing(c.data[k])
        error("Artifact $k is already set")
    end
    c.data[k] = v
end

Base.length(c::Context) = length(c.data)
Base.iterate(c::Context, x...) = iterate(c.data, x...)
Base.values(c::Context) = values(c.data)