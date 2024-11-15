using Distributions
using Random


@info "Doing stuff now …"


@show ARGS[1]
mu = try
    parse(Float64, ARGS[1])
catch error
    @error Cannot parse ARGS[1] to Float64
    rethrow()
end

@info "Drawing you your personal random numbers …"
@show rand(Normal(mu), 10)


@info "Done doing stuff."
