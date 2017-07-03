module DefferedAcceptance

function converter(a::Vector{Vector{Int}}, b::Vector{Vector{Int}})
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
    return a_2d, b_2d
end

# many-to-manyの関数を入れる
function ikegami(a::Vector{Vector{Int}}, b::Vector{Vector{Int}}, caps::Vector{Int})
    w = converter(a, b)
    a_2d = w[1]
    b_2d = w[2]
    return ikegamida_mm(a_2d, b_2d, caps)
end

function ikegami(a::Vector{Vector{Int}}, b::Vector{Vector{Int}})
    caps = ones(Int, length(b))
    w = converter(a, b)
    a_2d = w[1]
    b_2d = w[2]
    a, b, c =  ikegami(a_2d, b_2d, caps)
    return a, b
end


# one-to-one
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


# many-to-many
# capsがrespの時とpropの時とを関数内で場合分けする。

function ikegamida_mm(prop_prefs::Matrix{Int}, resp_prefs::Matrix{Int}, caps::Vector{Int})
    
    # set up
    prop_num, resp_num = size(prop_prefs)[2], size(resp_prefs)[2]
    # capsがrespの持つcapsの場合
    if length(caps) == resp_num
        
        match_or_unmatch = Array(Bool, prop_num)
        for i in 1:prop_num
            match_or_unmatch[i] = true
        end
        prop_matched, resp_matched = ones(Int64, prop_num) + resp_num, ones(Int64, sum(caps)) + prop_num

        prop_rank = Array(Int64, (resp_num + 1, prop_num))
        resp_rank = Array(Int64, (prop_num + 1, resp_num))

        sorting = Array(Int64, (resp_num + 1, 2))
        sorting[:, 1] = collect(1:(resp_num + 1))
        for i in 1:prop_num
            sorting[:, 2] = prop_prefs[:, i]
            prop_rank[:,i] = sortrows(sorting, by = x->(x[2]))[:,1]
            sorting = sortrows(sorting, by = x->(x[1]))
        end

        sorting2 = Array(Int64, (prop_num + 1, 2))
        sorting2[:, 1] = collect(1:(prop_num + 1))
        for i in 1:resp_num
            sorting2[:, 2] = resp_prefs[:, i]
            resp_rank[:,i] = sortrows(sorting2, by = x->(x[2]))[:,1]
            sorting2 = sortrows(sorting2, by = x->(x[1]))
        end

        insertarray = ones(Int64, maximum(caps) + 1) * (prop_num+1)

        #making indptr
        indptr = Array(Int, resp_num+1)
        indptr[1] = 1
        for i in 1:resp_num
            indptr[i+1] = indptr[i] + caps[i]
        end

        #main loop
        while sum(match_or_unmatch) > 0
            for i in 1:prop_num

                if match_or_unmatch[i] == true

                    for j in prop_prefs[:, i]

                        if j == 0
                            prop_matched[i] = 0
                            match_or_unmatch[i] = false
                            break

                        else
                            cutoff = resp_rank[1, j]

                            if resp_rank[i+1, j] < cutoff

                                #capを超えてないなら無条件まっち
                                if prop_num + 1 in resp_matched[indptr[j]:indptr[j+1]-1]

                                    for (m,q) in enumerate(resp_matched[indptr[j]:indptr[j+1]-1])

                                        if q == prop_num + 1
                                            resp_matched[indptr[j]+m-1] = i
                                            prop_matched[i] = j
                                            match_or_unmatch[i] = false
                                            break

                                        else
                                            if resp_rank[q+1, j] > resp_rank[i+1, j]      
                                                if m == 1
                                                    insertarray[m+1:length(resp_matched[indptr[j]:indptr[j+1]-1])] = resp_matched[indptr[j]:indptr[j+1]-1][m:end-1]
                                                    insertarray[m] = i
                                                else
                                                    insertarray[m+1:length(resp_matched[indptr[j]:indptr[j+1]-1])] = resp_matched[indptr[j]:indptr[j+1]-1][m:end-1]
                                                    insertarray[1:m-1] = resp_matched[indptr[j]:indptr[j+1]-1][1:m-1]  
                                                    insertarray[m] = i
                                                end
                                                resp_matched[indptr[j]:indptr[j+1]-1] = insertarray[1:length(resp_matched[indptr[j]:indptr[j+1]-1])]
                                                prop_matched[i] = j
                                                match_or_unmatch[i] = false
                                                break
                                            end
                                        end
                                    end
                                    break


                                #capを超えてたら競争
                                else
                                    for (n,p) in enumerate(resp_matched[indptr[j]:indptr[j+1]-1])      
                                        if resp_rank[p+1, j] > resp_rank[i+1, j]
                                            if n == 1
                                                insertarray[n+1:length(resp_matched[indptr[j]:indptr[j+1]-1])] = resp_matched[indptr[j]:indptr[j+1]-1][n:end-1]
                                                insertarray[n] = i
                                            else
                                                insertarray[n+1:length(resp_matched[indptr[j]:indptr[j+1]-1])] = resp_matched[indptr[j]:indptr[j+1]-1][n:end-1]
                                                insertarray[1:n-1] = resp_matched[indptr[j]:indptr[j+1]-1][1:n-1]
                                                insertarray[n] = i
                                            end
                                            match_or_unmatch[resp_matched[indptr[j]:indptr[j+1]-1][end]] = true
                                            prop_matched[resp_matched[indptr[j]:indptr[j+1]-1][end]] = resp_num + 1
                                            resp_matched[indptr[j]:indptr[j+1]-1] = insertarray[1:length(resp_matched[indptr[j]:indptr[j+1]-1])]
                                            prop_matched[i] = j
                                            match_or_unmatch[i]=false
                                            break
                                        end
                                    end
                                    if match_or_unmatch[i] == false
                                        break
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    
    # propがcapsを持つ時
    else
        match_or_unmatch = Array(Bool, prop_num)
        for i in 1:prop_num
            match_or_unmatch[i] = true
        end
        prop_matched, resp_matched = ones(Int64, sum(caps)) + resp_num, ones(Int64, resp_num) + prop_num

        prop_rank = Array(Int64, (resp_num + 1, prop_num))
        resp_rank = Array(Int64, (prop_num + 1, resp_num))

        sorting = Array(Int64, (resp_num + 1, 2))
        sorting[:, 1] = collect(1:(resp_num + 1))
        for i in 1:prop_num
            sorting[:, 2] = prop_prefs[:, i]
            prop_rank[:,i] = sortrows(sorting, by = x->(x[2]))[:,1]
            sorting = sortrows(sorting, by = x->(x[1]))
        end

        sorting2 = Array(Int64, (prop_num + 1, 2))
        sorting2[:, 1] = collect(1:(prop_num + 1))
        for i in 1:resp_num
            sorting2[:, 2] = resp_prefs[:, i]
            resp_rank[:,i] = sortrows(sorting2, by = x->(x[2]))[:,1]
            sorting2 = sortrows(sorting2, by = x->(x[1]))
        end

        insertarray = ones(Int64, maximum(caps) + 1) * (prop_num+1)

        #making indptr
        indptr = Array(Int, prop_num+1)
        indptr[1] = 1
        for i in 1:prop_num
            indptr[i+1] = indptr[i] + caps[i]
        end

        #main loop
        while sum(match_or_unmatch) > 0
            for i in 1:prop_num
                
                if match_or_unmatch[i] == false
                    break

                else
                    for j in prop_prefs[:, i]

                        # それ以降は0にして良い
                        if j == 0
                            for (n,t) in enumerate(prop_matched[indptr[i]:indptr[i+1]-1])
                                if t == resp_num + 1
                                    prop_matched[indptr[i]:indptr[i+1]-1][n] = 0
                                end
                            end
                            match_or_unmatch[i] = false
                            break

                        else
                            cutoff = resp_rank[1, j] # jが今proposeしている相手の持つ選考における0のランク

                            # proposeを受け入れてもいいなら…
                            if resp_rank[i+1, j] < cutoff

                                #マッチしてなければ無条件でマッチ
                                if prop_num + 1 == resp_matched[j]
                                    resp_matched[j] = i
                                    # ここでprop_matchedの場所を指定する必要
                                    m = sum(prop_matched[indptr[i]:indptr[i+1]-1] .!= resp_num+1)
                                    prop_matched[indptr[i]+m] = j
                                    
                                    # capが埋まったらfalseにしてbreak
                                    if m+1 == caps[i]
                                        match_or_unmatch[i] = false
                                        break
                                    end
                                    
                                #マッチしていたら競争
                                else
                                    rival = resp_matched[j]
                                    
                                    # rivalがかつ場合はするー
                                    # rivalが負ける場合
                                    if resp_rank[rival+1, j] > resp_rank[i+1, j]
                                        # rivalとか指定しなくても、prop_matchedにはもともとjは一人しかいないから、そこをreplaceすればいい？
                                        for (k,l) in enumerate(prop_matched)
                                            if l == j
                                                prop_matched[k] = resp_num + 1
                                            end
                                        end
                                        prop_matched[indptr[rival]:indptr[rival+1]-1] = sort(prop_matched[indptr[rival]:indptr[rival+1]-1])
                                        match_or_unmatch[rival] = true

                                        m = sum(prop_matched[indptr[i]:indptr[i+1]-1] .!= resp_num+1)
                                        prop_matched[indptr[i]+m] = j
                                        resp_matched[j] = i
                                        if m + 1 == caps[i]
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
        end
    end 
    
    
    for (i,t) in enumerate(prop_matched)
        if t == resp_num + 1
            prop_matched[i] = 0
        end
    end
    
    for (i,t) in enumerate(resp_matched)
        if t == prop_num + 1
            resp_matched[i] = 0
        end
    end
        
    return prop_matched, resp_matched, indptr
end

function ikegamida_mm(prop_prefs::Matrix{Int}, resp_prefs::Matrix{Int})
    caps = ones(Int, size(resp_prefs, 2))
    prop_matches, resp_matches, indptr = 
    ikegamida_mm(prop_prefs, resp_prefs, caps)
    return prop_matches, resp_matches
end

end