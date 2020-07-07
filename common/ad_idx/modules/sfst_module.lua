local M = { verison = "0.0.1" }

local utils = require('lib.utils')
local itypes = require('lib.itypes')
local cjson = require('cjson')
function M:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    return o
end

function M:init(uve)
    self.uve=uve
    self.uid= uve.uid
    self.product_name='sfst'
    self.ad_count = uve.ad_count * 2
end


function M:generate_request_body()
    self.request_body = utils.deepcopy(self.uve)
    return true
end

function M:generate_request()
    --if not itypes.is_non_empty_string(self.uid) then
    --    return false, {}
    --end
     
    local rc = self:generate_request_body()
    if rc == false then
        return false, {}
    end
    local body = self.request_body

    local body_str = cjson.encode(body)


    local api = "/ad/sfst"
    local request = {
        api,
        { 
            method = ngx.HTTP_POST, 
            body = body_str
        }
    }

    return true, request
end

function M:parse_response(http_response)
    local new_result_dict = {}
    for k, cands in pairs(http_response) do
        local new_cands = {}
        for _,cand in ipairs(cands) do
            if cand ~= nil then
                table.insert(new_cands, cand)
            end
        end
        if next(new_cands) ~= nil then
            new_result_dict[k] = new_cands
        end
    end
    self.result_dict = new_result_dict

end

return M
