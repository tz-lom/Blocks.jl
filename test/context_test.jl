@testset "Context" begin

    @artifact A = Int
    @artifact B = String
    @artifact C = Float64

    ctx = Blocks.Context([A,B,C])
    @test all(isnothing, values(ctx)) == true

    ctx[A] = Some(4)
    ctx[B] = Some("foo")

    @test something(ctx[A]) == 4
    @test something(ctx[B]) == "foo"
    @test isnothing(ctx[C])

    @test_throws ErrorException ctx[A] = Some(5)

end