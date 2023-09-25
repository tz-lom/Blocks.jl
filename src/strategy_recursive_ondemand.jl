struct RecursiveOnDemand
    plan::ExecutionPlan
    context::Context

    # function RecursiveOnDemand(plan::ExecutionPlan)
    #     return new(plan, g)
    # end
end

function Base.setindex!(strategy::RecursiveOnDemand, value::Some{T}, idx::Type{<:Artifact{T}}) where T 
    strategy.context[idx] = value
end

function Base.getindex(strategy::RecursiveOnDemand, artifact::Type{<:Artifact})
    current = strategy.context[artifact]
    if !isnothing(current)
        return something(current)
    end

    provider = provider_for_artifact(strategy.plan, artifact)

    #@todo: conditionals will give a problem here
    strategy.context[provider.output] = Some(provider((x)->strategy[x]))
    return something(strategy.context[artifact])
end
