abstract type Provider end

struct CallableProvider <: Provider
    call::Function
    inputs::Vector{Type{<:Artifact}}
    output::Type{<:Artifact}

    function CallableProvider(call, inputs, output)
        name = Symbol(call)
        if unique(inputs) != inputs
            error("All inputs of provider $name should be unque artifacts")
        end
        if output in inputs
            error("Provider $name can't return $output and take it as an input at the same time")
        end
        return new(call, inputs, output)
    end
end

function (p::CallableProvider)(artifact_source) 
    return p.call([artifact_source(inp) for inp in p.inputs]...)
end

describe_provider(p::T) where {T<:Provider} = p 


function read_function_signature(func::Expr) #::NamedTuple{(:name, :result, :args),Tuple{Symbol,UnionAll,Vector{Tuple{Symbol,UnionAll}}}}
    if func.head != :function
        throw(DomainError(func, "Have to be a function"))
    end
    signature = func.args[1]

    if signature.head != :(::)
        throw(DomainError(func, "Provider function should explicitly return type"))
    end

    result = signature.args[2]

    name = signature.args[1].args[1]
    arguments = map(enumerate(signature.args[1].args[2:end])) do (i, arg)
        if typeof(arg) != Expr
            throw(DomainError(func, "Argument $i ($arg) have no type specification"))
        end
        if arg.head == :parameters
            throw(DomainError(func, "Keyword based parameters are not supported"))
        end
        if arg.head == :kw
            throw(DomainError(func, "Default values of the arguments are not supported"))
        end
        if arg.head != :(::)
            throw(DomainError(func, "Argument $i ($arg) have to be argument specification"))
        end
        return arg.args[1], arg.args[2]
    end
    return (name=name, result=result, args=arguments)
end


macro provider(func::Expr)
    @match func begin
        Expr(:function, _) => begin
            sig = read_function_signature(func)

            extract_type = (type) -> :(Blocks.artifact_type($type))
            new_signature = Expr(
                :(::),
                Expr(
                    :call,
                    sig.name,
                    map((args,) -> Expr(:(::), args[1], extract_type(args[2])), sig.args)...
                ),
                extract_type(sig.result)
            )

            new_function = func
            new_function.args[1] = new_signature

            inputs = map((arg) ->esc(arg[2]), sig.args)

            name = esc(sig.name)
            output = esc(sig.result)

            return quote
                $(esc(new_function))
                local definition = Blocks.CallableProvider($name, [$(inputs...)], $output)
                function Blocks.describe_provider(::typeof($name))
                    return definition
                end
                Blocks.is_provider(::typeof($name)) = true
            end
        end
        Expr(:(::), [Expr(:call, [name, inputs...]), output]) => begin
            name = esc(name)
            inputs = map(esc, inputs)
            output = esc(output)
            return quote
                local definition = Blocks.CallableProvider($name, [$(inputs...)], $output)
                function Blocks.describe_provider(::typeof($name))
                    return definition
                end
                Blocks.is_provider(::typeof($name)) = true
            end
        end
        Expr(:(=), [name, Expr(:(::), [Expr(:call, [alias, inputs...]), output])]) => begin 
            name = esc(name)
            alias = esc(alias)
            inputs = map(esc, inputs)
            output = esc(output)
            return quote
                $name(args...) = $alias(args...)
                local definition = Blocks.CallableProvider($name, [$(inputs...)], $output)
                function Blocks.describe_provider(::typeof($name))
                    return definition
                end
                Blocks.is_provider(::typeof($name)) = true
            end
        end
        _ => throw(DomainError(func, "Can't make provider with given definition"))
    end
end

is_provider(_) = false

# function discover_artifact(func::Expr, t::Type{<:Artifact})
# end
