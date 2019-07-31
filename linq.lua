local utility = {}
utility.returnValue = function(v) return v end
utility.returnTrue = function(v) return true end

local _where = function(self, comp)
    local advanceIter = function(data, i)
        while (true) do
            local v
            i, v = self.advanceIter(data, i)
            if v then
                if not comp or comp(v) then
                    return i, v
                end
            else
                return nil
            end
        end
    end

    return Enum("where", self.getData, advanceIter)
end

local _select = function(self, selector)
    selector = selector or function(v) return v end
    local advanceIter = function(data, i)
            local v
            i, v = self.advanceIter(data, i)
            if v then
                return i, selector(v)
            end
        end

    return Enum("select", self.getData, advanceIter)
end

local _reverse = function(self)
    local advanceIter = function(data, i)
            local v
            i = i + 1
            local v = data[i]
            if v then
                return i, v
            else
                return nil
            end
        end

    local getData = function(_self)
            local x = {}
            for k,v in ipairs(self) do
                if v then 
                    table.insert(x, 1, v)
                end
            end
            return x
        end

    return Enum("reverse", getData, advanceIter)
end

local _toArray = function(self)
    local x = {}
    for k,v in ipairs(self) do
        if v then 
            x[#x+1] = v 
        end
    end

    return x
end

local _first = function(self)
    for k,v in ipairs(self) do
        return v
    end

    return nil
end

local _last = function(self)
    local x = nil
    for k,v in ipairs(self) do
        x = v
    end

    return x
end

local _aggregate = function(self, seed, func, resultSelector)
    local result = seed
    for k,v in ipairs(self) do
        result = func(result, v)
    end
    if resultSelector then
        result = resultSelector(result)
    end
    return result
end

local _average = function(self, func)
    func = func or utility.returnValue
    local sum = 0
    local count = 0
    for k,v in ipairs(self) do
        count = count + 1
        sum = sum + func(v)
    end
    return sum / count
end

local _sum = function(self, func)
    func = func or utility.returnValue
    local sum = 0
    for k,v in ipairs(self) do
        sum = sum + func(v)
    end
    return sum
end

local _count = function(self, predicate)
    predicate = predicate or utility.returnTrue
    local countOpe = function(r, v) if predicate(v) then return r + 1 else return r end end
    return self:aggregate(0, countOpe)
end

local xcomp = function(self, comp)
    local result
    for k,v in ipairs(self) do
        if not result or not comp(result, v) then 
            result = v
        end
    end
    return result
end

local _max = function(self, comp)
    comp = comp or function(l, r) return l >= r end
    return xcomp(self, comp)
end

local _min = function(self, comp)
    comp = comp or function(l, r) return l <= r end
    return xcomp(self, comp)
end

local function iter (a, i)
    i = i + 1
    local v = a[i]
    if v then
       return i, v
    end
end

Enum = function (_operator, _getData, _advanceIter)
    local enum = {}
    local methods = { 
        __is_linq = true, getData = _getData, advanceIter = _advanceIter, 
        where = _where, 
        select = _select,
        reverse = _reverse,
        toArray = _toArray, 
        first = _first, 
        last = _last, 

        aggregate = _aggregate,
        average = _average,
        count = _count,
        max = _max,
        min = _min,
        sum = _sum,
        operator = _operator }
    local _linq = { __index = methods , __ipairs = function(_self)
            local data = _self:getData()
            local index = 0

            return _self.advanceIter, data, index
        end }
    return setmetatable(enum, _linq)
end

local from = function (source)
    source = source or {}

    local selfAdvanceIter
    local getData
    if source.__is_linq then
        selfAdvanceIter = source.advanceIter
        getData = source.getData
    else
        selfAdvanceIter = function(data, i)
                i = i + 1
                local v = data[i]
                return i, v
            end
        getData  = function(self)
                return source
            end
    end

    local advanceIter = function(data, i)
            local v
            i, v = selfAdvanceIter(data, i)
            if v then
                return i, v
            end
        end

    return Enum("from", getData, advanceIter)
end

local Generation = {
    _range = function(r)
        local x = {}
        for i = 1,r,1 do
            x[i] = i
        end
        return from(x)
    end,

    _repeat = function(e,n)
        local x = {}
        for i = 1,n,1 do
            x[i] = e
        end
        return from(x)
    end,

    _empty = function()
        local x = {}
        return from(x)
    end,

    _defaultIfEmpty = function(array, default)
        if not array or next(array) == nil then
            local x = { default }
            return from(x)
        else
            return from(array)
        end
    end
}

return { 
    from = from, 
    range = Generation._range,
    repeatValue = Generation._repeat,
    empty = Generation._empty,
    defaultIfEmpty = Generation._defaultIfEmpty
}