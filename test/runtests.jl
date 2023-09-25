using ReTest, Blocks

module TestBlocks_AP
using ReTest, Blocks
include("artifact_and_provider_definitions_test.jl")
end

module TestBlocks_Context
using ReTest, Blocks
include("context_test.jl")
end

module TestBlocks_StraRecOnDem
using ReTest, Blocks
include("strategy_recursive_ondemand_test.jl")
end

module TestBlocks_Conditional
using ReTest, Blocks
include("conditional_test.jl")
end

retest(TestBlocks_AP, TestBlocks_Context, TestBlocks_StraRecOnDem, TestBlocks_Conditional)
