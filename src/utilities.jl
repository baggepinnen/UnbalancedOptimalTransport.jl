# Numerically stable implementation of `w -> log(sum(exp, w))`.
# https://discourse.julialang.org/t/fast-logsumexp/22827/9
function logsumexp!(w)
    N = length(w)
    offset, maxind = findmax(w)
    w .= exp.(w .- offset)
    Σ = _sum_all_but(w, maxind)
    log1p(Σ) + offset
end

# Add all elements of vector `w` except for index `i`.
# The element at index `i` is assumed to have value 1
function _sum_all_but(w, i)
    w[i] -= 1
    s = sum(w)
    w[i] += 1
    s
end

"""
    fdot(f, u, v) -> Number

A generic, allocation-free implementation of `dot(u, f.(v))`. It may be faster
to provide a specialized method to dispatch to BLAS or so forth.
"""
function fdot(f, u, v)
    T = promote_type(eltype(u), eltype(v))
    s = zero(T)
    @inbounds for i in eachindex(u, v)
        s += conj(u[i]) * f(v[i])
    end
    s
end

function handle_C(C::AbstractMatrix,a,b)
    size(C) == (length(a), length(b)) ||
        throw(ArgumentError("The dimension of the cost matrix C does not match the length of the measures. Got $(size(C)), $((length(a), length(b)))"))
    C
end

function handle_C(C,a,b)
    x = a.set
    y = b.set
    [C(x, y) for x in x, y in y]
end
