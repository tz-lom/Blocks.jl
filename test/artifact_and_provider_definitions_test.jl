@testset "Declare artifact" begin
    @artifact A = Int
    @test is_artifact(A) == true
    @test is_artifact(Int) == false
    @test Blocks.artifact_type(A) == Int
end

@testset "Declare provider as function" begin
    @artifact A = Int
    @artifact B = Int
    @artifact C = Int
    
    @provider function foo(a::A, b::B)::C
        return a + b
    end

    a = A(1)
    b = B(3)
    expected = C(4)
    @test foo(a, b) == expected

    @test is_provider(foo) == true
    
    descr = Blocks.describe_provider(foo)
    @test descr.call == foo
    @test descr.inputs == [A, B]
    @test descr.output == C
end

@testset "Declare existing function as provider" begin
    @artifact A = Int
    @artifact B = Int

    @test is_provider(abs) == false
    @provider abs(A)::B
    @test is_provider(abs) == true

    expected = B(3)
    @test abs(A(-3)) == expected

    descr = Blocks.describe_provider(abs)
    @test descr.call == abs
    @test descr.inputs == [A]
    @test descr.output == B
end


@testset "Declare alias to existing function as provider" begin
    @artifact A = Int
    @artifact B = Int
    @artifact C = Int

    @test is_provider(max) == false
    @provider foo=max(A, B)::C
    @test is_provider(max) == false
    @test is_provider(foo) == true

    expected = C(3)
    @test foo(A(-1), B(3)) == expected

    descr = Blocks.describe_provider(foo)
    @test descr.call == foo
    @test descr.inputs == [A, B]
    @test descr.output == C
end

@testset "Reject unsupported syntax of @provider" begin
    @artifact A = Int
    @artifact B = Int

    @test_throws "Provider function should explicitly return type" eval(:(@provider function foo(x) end))
    @test_throws "Argument 1 (x) have no type specification" eval(:(@provider function foo(x)::Int end))
    
    @test_throws "All inputs of provider foo should be unque artifacts" eval(:(@provider function foo(x::A, y::A)::B end))
    @test_throws r"Provider foo can't return .+?\.A and take it as an input at the same time" eval(:(@provider function foo(x::A)::A end))
        
    @test_throws "All inputs of provider max should be unque artifacts" eval(:(@provider max(A, A)::B))
    @test_throws r"Provider abs can't return .+?\.A and take it as an input at the same time" eval(:(@provider abs(A)::A))
            

    @test_throws "Can't make provider with given definition" eval(:(@provider 2+2))
end

