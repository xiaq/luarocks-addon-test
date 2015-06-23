local test = {}

-- XXX Uses unstable API of luarocks.fs and luarocks.fetch
local fs = require("luarocks.fs")
local fetch = require("luarocks.fetch")
local api = require("luarocks.api")

local modules_from_rockspec

local function find_test(filename)
    local ext = filename:match("%.[^/\\]*$")
    local test_filename = filename:sub(1, -1-#ext).."_test"..ext
    return fs.exists(test_filename) and test_filename or nil
end

local function run_tests(modules)
    if not modules then
        modules = modules_from_rockspec
    end
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
            print("NO TEST FILE "..filename..", skipped")
        end
    end
end

function test.load()
    api.register_rockspec_field("test", { _more = true },
        function(m) modules_from_rockspec = m end)
    api.register_hook("build.after", run_tests)
end

function test.run(filename)
    local rockspec, err, errcode = fetch.load_rockspec(filename)
    if err then
        return nil, err, errcode
    end
    run_tests(rockspec.test)
    return true
end

return test
