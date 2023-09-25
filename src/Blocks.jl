module Blocks

export @artifact, @provider, @conditional
export is_artifact
export is_provider, describe_provider
export ProviderSet
export ExecutionPlan
export RecursiveOnDemand

import Base
using Match


include("artifact.jl")
include("provider.jl")
include("context.jl")
include("execution_plan.jl")
include("strategy_recursive_ondemand.jl")
include("conditional.jl")

end
