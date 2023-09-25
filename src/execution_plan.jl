struct ProviderSet 
    set::Set{Provider}

    function ProviderSet(items::Vector)
        new(Set(map(describe_provider, items)))
    end
end

Base.length(p::ProviderSet) = Base.length(p.set)
Base.iterate(p::ProviderSet, i...) = Base.iterate(p.set, i...)


struct ExecutionPlan
    inputs
    outputs
    artifacts
    provider_for_artifact::Dict{Type{<:Artifact}, Provider}

    function ExecutionPlan(providers::ProviderSet)
        # @todo: check for unique provider output
        # @todo: check that graph does not split into subgraphs
        # @todo: extract artifact types from graph
        provider_for_artifact = Dict([p.output => p for p in providers])
        
        return new([], [], [], provider_for_artifact)
    end
end 

function provider_for_artifact(plan::ExecutionPlan, artifact::Type{<:Artifact})::Provider
    return plan.provider_for_artifact[artifact]
end

function as_dot()
end
