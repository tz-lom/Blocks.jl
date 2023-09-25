
struct PromoteProvider <: Provider
    input::Type{<:Artifact}
    output::Type{<:Artifact}

    function PromoteProvider(call, inputs, output)
        if input == output
            error("You shouldn't promote artifact $input to the same artifact")
        end
        return new(input, output)
    end
end

(p::PromoteProvider)(x) = p.output(x)