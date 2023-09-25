
struct ConditionalProvider <: Provider
    name::Symbol
    condition::Type{<:Artifact}
    if_true::Type{<:Artifact}
    if_false::Type{<:Artifact}
    output::Type{<:Artifact}

    # function ConditionalProvider(name, condition, if_true)
    #     if unique(inputs) != inputs
    #         error("All inputs of provider $name should be unque artifacts")
    #     end
    #     if output in inputs
    #         error("Provider $name can't return $output and take it as an input at the same time")
    #     end
    #     return new(name, inputs, output)
    # end
end

function (p::ConditionalProvider)(artifact_source)
    if artifact_source(p.condition)
        artifact_source(p.if_true)
    else
        artifact_source(p.if_false)
    end
end



macro conditional(e::Expr)
    @match e begin
        Expr(:(=), [Expr(:(::), [name, output]), Expr(:if, [condition, if_true, if_false])]) => begin
            sname = string(name)
            name = esc(name)
            condition = esc(condition)
            if_true = esc(if_true)
            if_false = esc(if_false)
            output = esc(output)
            return quote
                $name = Blocks.ConditionalProvider(Symbol($sname), $condition, $if_true, $if_false, $output)
                function Blocks.describe_provider(::typeof($name))
                    return definition
                end
                Blocks.is_provider(::typeof($name)) = true
            end
        end
        _ => throw(DomainError(func, "Can't make conditional provider from given definition"))
    end
end