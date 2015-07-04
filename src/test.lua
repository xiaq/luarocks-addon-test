local test = {}

local api = require("luarocks.api")

local function find_test(filename)
    local ext = filename:match("%.[^/\\]*$")
    local test_filename = filename:sub(1, -1-#ext).."_test"..ext
    return api.exists(test_filename) and test_filename or nil
end

local function run_tests(rockspec)
    local modules = rockspec.build.modules
    for modname, filename in pairs(modules) do
        io.write("Testing module "..modname..": ")
        local test = find_test(filename)
        if test then
            local ok, err = pcall(dofile, test)
            if ok then
                print("SUCCESS")
            else
                print("FAIL: "..err)
            end
        else
            print("NO TEST FILE FOR "..filename..", skipped")
        end
    end
end

function test.load()
    api.register_hook("build.after", run_tests)
end

function test.run(filename)
    local rockspec, err, errcode = api.load_rockspec(filename)
    if err then
        return nil, err, errcode
    end
    run_tests(rockspec)
    return true
end

return test
