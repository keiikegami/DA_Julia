function ikegamida_mm(prop_prefs::Matrix{Int}, resp_prefs::Matrix{Int}, caps::Vector{Int})
    
    # set up
    prop_num, resp_num = size(prop_prefs)[2], size(resp_prefs)[2]
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
