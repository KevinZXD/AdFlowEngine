-----------------------------------------------------------------------------
-- 处理ad结构的请求
-- 包括 博文推广(bidfeed)、品牌速递（brand）、微博精选（aim）、非粉（nofans）、粉丝头条（body）
-- 无需调用redis或者接口，在本模块里直接组装好数据格式返回
-- 返回给端上的具体的数据结构由mapi组装
-----------------------------------------------------------------------------
module(..., package.seeall)



function new(self)
    return setmetatable({}, { __index = self })
end

function run(self)

    local cjson = require('cjson')
    ngx.req.read_body()
    local post_params = ngx.req.get_body_data()
    local status
    status, post_params = pcall(cjson.decode, post_params)

    self.post_params = post_params
    local mock = [[
     {"recommend": "热门",
      "id": "4523297448293259",
       "service": "mainfeed",
       "adtype": 8,
       "type": "ad",
       "product":"a"
            }
    ]]
    ngx.print(mock)
    ngx.eof()
    self.finish(self)
end
