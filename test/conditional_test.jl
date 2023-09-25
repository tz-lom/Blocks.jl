@testset "Simple conditional usecase" begin
    # A -p1-> B
    # A -p2-> C
    # D?B|C -p3-> E 

    @artifact A = Int
    @artifact B = Int
    @artifact C = Int
    @artifact D = Bool
    @artifact E = Int

    @provider function p1(x::A)::B return x + 1; end
    @provider function p2(x::A)::C return x * 2; end
    
    @conditional p3::E = D ? B : C

    #@todo: describe_provider should be called in provider set implicitly
    providers = ProviderSet([describe_provider(p1), describe_provider(p2), p3])
    plan = ExecutionPlan(providers)

    strategy = RecursiveOnDemand(plan, Blocks.Context([A,B,C,D,E]))

    strategy[D] = Some(true)
    strategy[A] = Some(1)
    @test strategy[E] == 2

end