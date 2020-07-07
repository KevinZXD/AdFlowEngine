local M = { verison = "0.0.1" }

local utils = require('lib.utils')
local cjson = require('cjson')
function M:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    self.product_name='sfst'
    return o
end

function M:init()

end


function M:generate_request_body(params)

    self.request_body = utils.deepcopy(params)
    return true
end

function M:generate_request(params)

    local rc = self:generate_request_body(params)
    if rc == false then
        return false, {}
    end
    local body = self.request_body

    local body_str = cjson.encode(body)

    local api = "/ad/"..self.product_name
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
