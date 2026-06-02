local numerical_units = {
    "",
    "十",
    "百",
    "千",
    "万",
    "十",
    "百",
    "千",
    "亿",
    "十",
    "百",
    "千",
    "兆",
    "十",
    "百",
    "千",
}

local numerical_names = {
    "零",
    "一",
    "二",
    "三",
    "四",
    "五",
    "六",
    "七",
    "八",
    "九",
}

local function convert_arab_to_chinese(number)
    local n_number = tonumber(number)
    assert(n_number, "传入参数非正确number类型!")

    if n_number < 10 then
        return numerical_names[n_number + 1]
    end
    if n_number < 20 then
        local digit = string.sub(n_number, 2, 2)
        if digit == "0" then
            return "十"
        else
            return "十" .. numerical_names[digit + 1]
        end
    end

    local len_max = 9
    local len_number = string.len(number)
    assert(
        len_number > 0 and len_number <= len_max,
        "传入参数位数" .. len_number .. "必须在(0, " .. len_max .. "]之间！"
    )

    local numerical_tbl = {}
    for i = 1, len_number do
        numerical_tbl[i] = tonumber(string.sub(n_number, i, i))
    end

    local pre_zero = false
    local result = ""
    for index, digit in ipairs(numerical_tbl) do
        local curr_unit = numerical_units[len_number - index + 1]
        local curr_name = numerical_names[digit + 1]
        if digit == 0 then
            if not pre_zero then
                result = result .. curr_name
            end
            pre_zero = true
        else
            result = result .. curr_name .. curr_unit
            pre_zero = false
        end
    end
    result = string.gsub(result, "零+$", "")
    return result
end

local function convert_digits(number, alt_zero)
    local num_str = tostring(number)
    local result = {}

    for i = 1, #num_str do
        local ch = num_str:sub(i, i)
        local digit = tonumber(ch)

        if digit == 0 then
            table.insert(result, alt_zero and "〇" or "零")
        else
            table.insert(result, numerical_names[digit + 1])
        end
    end

    return table.concat(result)
end

return {
    convert = convert_arab_to_chinese,
    digits = convert_digits
}
