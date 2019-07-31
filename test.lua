local linq = require("linq")

function printArray(array)
    for k,v in ipairs(array) do
        print(v)
    end
end

function isOddNumber(num)
    return num % 2 ~= 0
end

function isEvenNumber(num)
    return num % 2 == 0
end

local vs = linq.range(5)
printArray(vs)

print("--------")
local vs2 = linq.repeatValue(10,3)
printArray(vs2)

print("--------")
local vs3 = linq.empty()
printArray(vs3)

print("--------")
printArray(linq.defaultIfEmpty({1,2,3}, 1))
printArray(linq.defaultIfEmpty({}, 99))

print("--------")
printArray(vs:where(isEvenNumber))

print("--------")
printArray(vs:reverse())

print("--------")
printArray(vs:where(isEvenNumber):select(function(v) return v + 1 end):toArray())

print("--------")
print(vs:aggregate(0, function(t, n) return t + n end, function(r) return r / 2 end))
