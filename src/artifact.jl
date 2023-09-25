abstract type Artifact{T} end

macro artifact(ex::Expr)
    if ex.head != :(=)
        throw("Have to be an assignment expression like @artifact A=Int")
    end
    name = esc(ex.args[1])
    type = esc(ex.args[2])
    return quote
        struct $name <: Artifact{$type}
            $name(args...) = $type(args...)
        end
    end
end

artifact_type(::Type{<:Artifact{T}}) where {T} = begin 
    T
 end
# artifact_type(s::Symbol) = artifact_type(eval(s))

is_artifact(::Type{<:Artifact}) = true
is_artifact(_) = false

