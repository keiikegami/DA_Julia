module DefferedAcceptance
    function ikegami(m_prefs::Vector{Vector{Int}}, f_prefs::Vector{Vector{Int}})
        m = length(m_prefs)
        n = length(f_prefs)

        m_prefs_2d = Matrix{Int64}(n+1, m)
        n_prefs_2d = Matrix{Int64}(m+1, n)

        for (t,i) in enumerate(m_prefs)
            if length(i) != n
                new_element = Array(Int, n+1-length(i))
                new_element[1] = 0
                new_element[2:end] = [j for j in range(1,n) if !(j in i)]
                m_prefs[t] = append!(i, new_element)
            else
                m_prefs[t] = push!(i, 0)
            end
            m_prefs_2d[:, t] = m_prefs[t]
        end

        for (t,i) in enumerate(n_prefs)
            if length(i) != m
                new_element = Array(Int, m+1-length(i))
                new_element[1] = 0
                new_element[2:end] = [j for j in range(1,m) if !(j in i)]
                n_prefs[t] = append!(i, new_element)
            else
                n_prefs[t] = push!(i, 0)
            end
            n_prefs_2d[:, t] = n_prefs[t]
        end

        return ikegamida(m_prefs_2d, n_prefs_2d)
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