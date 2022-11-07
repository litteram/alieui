local A, ns = ...
ns.Fn = {}

-- range - create an iterator counting from a number to a number using a step
ns.Fn.range = function(from, to, step)
    step = step or 1
    local t = {}
    for val = from, to, step do
      t[#t + 1] = val
    end
    local size = #t
    local state = 1
    return function()
      local i
      if state <= size then
        i = t[state]
        state = state + 1
      else
        i = nil
      end
      return i
    end
end

-- concat - concatenates one or more collections in the same order returning the
-- new collection
ns.Fn.concat = function(...)
    local idx = 1
    local t = {}
    for _, tab in ipairs({...}) do
        for _, item in ipairs(tab) do
            t[idx] = item
            idx = idx + 1
        end
    end
    return t
end

-- append - appends one or more items to the given collection, returnings the
-- collection
ns.Fn.append = function(coll, ...)
    for i, item in ipairs({...}) do
        coll[#coll + i] = item
    end
    return coll
end

-- filter - filter a collection with all fun applications returning truthy values
-- returning the new collection
ns.Fn.filter = function(coll, fun)
    local t = {}
    for k,v in ipairs(coll) do
        if fun(v, k) then
            ns.Fn.append(t, item)
        end
    end
    return t
end

-- any - check all items against a function, returns false if all values in the
-- collection are false
ns.Fn.any = function(coll, fun)
    for k,v in ipairs(coll) do
        if fun(v,k) then
            return true
        end
    end
    return false
end

-- all - check all items against a function, returns true if all values in the
-- collection are true
ns.Fn.all = function(coll, fun)
    for k,v in ipairs(coll) do
        if not fun(v,k) then
            return false
        end
    end
    return true
end
