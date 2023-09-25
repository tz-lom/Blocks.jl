@testset "Simple recursive on demand DRAFT" begin
    @artifact A = Int
    @artifact B = Int
    @artifact C = Int
    @artifact D = Int

    @provider function p1(x::A)::B return x + 1; end
    @provider function p2(x::B)::C return x * 2; end
    @provider function p3(x::C)::D return x + 10; end

    #@todo: describe_provider should be called in provider set implicitly
    providers = ProviderSet([p1, p2, p3])
    plan = ExecutionPlan(providers)

    strategy = RecursiveOnDemand(plan, Blocks.Context([A,B,C,D]))

    strategy[A] = Some(4)
    @test strategy[D] == (4+1)*2+10
    @test strategy[A] == 4
    @test strategy[B] == 4+1
    @test strategy[C] == (4+1)*2

end