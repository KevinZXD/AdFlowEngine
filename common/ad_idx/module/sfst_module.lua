local M = { verison = "0.0.1" }

local utils = require('utils')
local itypes = require('itypes')
function M:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    return o
end

function M:init(uve, params)

end


function M:generate_request_body()
    self.request_body = utils.deepcopy(self.uve)
    return true
end

function M:generate_request()
    if not itypes.is_non_empty_string(self.user_identifier) then
        return false, {}
    end
     
    local rc = self:generate_request_body()
    if rc == false then
        return false, {}
    end
    local body = self.request_body

    self.basic:set_request_body(body)

    local body_str = IdxUtil.encode_request_body(body, self.follow_list_json_str)


    local api = string.format("/ad/%s/%s?api=%s&bl_key=%s&ups=%s", 
                              D.PRODUCTS.SFST, self.uve.service,
                              "sfst", self.user_identifier, self.ups)
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
            if self:check_candidate(cand) ~= nil then
                table.insert(new_cands, cand)
            end
        end
        if next(new_cands) ~= nil then
            new_result_dict[k] = new_cands
        end
    end
    self.basic.result_dict = new_result_dict

end

return M
