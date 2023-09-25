
Artifact - data, either input data or result of computations. Defined with `@artifact`, see `is_artifact` and `artifact_type`
Provider - function which takes Artifacts as an input and provides single Artifact on output. Should be pure function (no side effects). Defined with `@provider`, see `is_provider` and `provider_definition`


Context - set of Artifacts. Artifacts can be either resolved or not, initially all of them are unresolved. 

ProviderSet - set of Providers.
ExecutionPlan - verified set of Providers, contains meta-data about dependencies between Providers (based on consumed and produced Artifacts). Use `inputs` to list Artifacts which would be only consumed by Providers, `outputs` to list Artifacts which would be only produced by Providers and `intermediate` to list Artifacts which would be both produced and consumed by Providers.

ExecutionStrategy - abstract class of strategies, their goal is to provide some way of Artifact evaluations.

TakeAllMakeAll <: ExecutionStrategy - takes all `inputs` as arguments and returnes fullly definied Context
RecursiveOnDemand <: ExecutionStrategy - Artifacts are provided one by one, in case of

```
A -p1-> B
A -p2-> C

D?B|C -p3-> E 

function f(A, D)
  if D
    B = p1(A)
    E = p3(B)
  else
    C = p2(A)
    E = p4(C)
  end
  return E
end


B = lazy(p1, A)
C = lazy(p2, A)

E = if D
  lazy(p3, B())
else
  lazy(p4, C())
end

return E



```