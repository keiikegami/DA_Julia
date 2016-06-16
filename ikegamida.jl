function ikegamida(m_prefs, f_prefs)
    
    m_num, f_num = size(m_prefs)[2], size(f_prefs)[2]
    m_pool, f_pool = collect(1:m_num), collect(1:f_num)
    m_matched, f_matched = ones(Int64, m_num) + f_num, ones(Int64, f_num) + m_num
    
    while length(m_pool) != 0
        i = pop!(m_pool)
        
        for j in m_prefs[:, i]
            
            if j == 0
                m_matched[i] = 0
                break
            
            else
                no_marriage = indexin([0], f_prefs[:,j])[1]
                
                if indexin([i], f_prefs[:, j])[1] < no_marriage
                    
                    if f_matched[j] == m_num + 1
                        f_matched[j] = i
                        m_matched[i] = j
                        break
                        
                    else
                    
                        if indexin([f_matched[j]], f_prefs[:, j])[1] > indexin([i], f_prefs[:, j])[1]
                            push!(m_pool, f_matched[j])
                            f_matched[j] = i
                            m_matched[i] = j
                            break
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