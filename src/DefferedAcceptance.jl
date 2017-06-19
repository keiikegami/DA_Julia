module DefferedAcceptance

function ikegami(a::Vector{Vector{Int}}, b::Vector{Vector{Int}})
    m = length(a)
    n = length(b)

    a_2d = Matrix{Int64}(n+1, m)
    b_2d = Matrix{Int64}(m+1, n)

    for (t,i) in enumerate(a)
        if length(i) != n
            a_2d[1:length(i), t] = i
            a_2d[length(i)+1, t] = 0
            a_2d[(length(i)+2):end, t] = Array([j for j in 1:n if !(j in i)])
        else
            a_2d[1:length(i), t] = i
            a_2d[length(i)+1, t] = 0
        end
    end

    for (t,i) in enumerate(b)
        if length(i) != m
            b_2d[1:length(i), t] = i
            b_2d[length(i)+1, t] = 0
            b_2d[length(i)+2:end, t] = Array([j for j in 1:m if !(j in i)])
        else
            b_2d[1:length(i), t] = i
            b_2d[length(i)+1, t] = 0
        end
    end

    return ikegamida(a_2d, b_2d)
end



function ikegamida(m_prefs, f_prefs)

    m_num, f_num = size(m_prefs)[2], size(f_prefs)[2]
    m_pool, f_pool = collect(1:m_num), collect(1:f_num)
    match_or_unmatch = Array(Bool, m_num)
    for i in 1:m_num
        match_or_unmatch[i] = true
    end
    m_matched, f_matched = ones(Int64, m_num) + f_num, ones(Int64, f_num) + m_num

    m_rank = Array(Int64, (f_num + 1, m_num))
    f_rank = Array(Int64, (m_num + 1, f_num))

    sorting = Array(Int64, (f_num + 1, 2))
    sorting[:, 1] = collect(1:(f_num + 1))

    for i in 1:m_num
        sorting[:, 2] = m_prefs[:, i]
        m_rank[:,i] = sortrows(sorting, by = x->(x[2]))[:,1]
        sorting = sortrows(sorting, by = x->(x[1]))
    end


    sorting2 = Array(Int64, (m_num + 1, 2))
    sorting2[:, 1] = collect(1:(m_num + 1))

    for i in 1:f_num
        sorting2[:, 2] = f_prefs[:, i]
        f_rank[:,i] = sortrows(sorting2, by = x->(x[2]))[:,1]
        sorting2 = sortrows(sorting2, by = x->(x[1]))
    end

    while sum(match_or_unmatch) > 0
        for i in 1:m_num
            if match_or_unmatch[i] == true

                for j in m_prefs[:, i]

                    if j == 0
                        m_matched[i] = 0
                        match_or_unmatch[i] = false
                        break

                    else
                        no_marriage = f_rank[1, j]
                        print(no_marriage)
                        print(f_rank[i+1, j]) #ここが2となっている。本当は5。→最初の整形の段階でちゃんと残ったやつを入れてあげないとダメか。

                        if f_rank[i+1, j] < no_marriage

                            if f_matched[j] == m_num + 1
                                f_matched[j] = i
                                m_matched[i] = j
                                match_or_unmatch[i] = false
                                break

                            else

                                if f_rank[f_matched[j]+1, j] > f_rank[i+1, j]
                                    match_or_unmatch[f_matched[j]] = true
                                    f_matched[j] = i
                                    m_matched[i] = j
                                    match_or_unmatch[i] = false
                                    break
                                end
                            end
                        end
                    end
                end
            end
        end
    end

    for (i,t) in enumerate(f_matched)
        if t == m_num + 1
            f_matched[i] = 0
        end
    end

     for (i,t) in enumerate(m_matched)
        if t == f_num + 1
            m_matched[i] = 0
        end
    end

    return m_matched, f_matched
end
end