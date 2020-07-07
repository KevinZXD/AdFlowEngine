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
    local body = http_response.body
    local body_json = cjson.decode(body)
    self.result_dict = body_json

end

return M
