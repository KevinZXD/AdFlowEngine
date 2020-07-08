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
    post_params = cjson.decode(post_params)
    local post_body = post_params.post_body
    post_body.strategy_products={'sfst'}
    if post_body.ad_counts then
        ads_assign( post_body.ad_counts,post_body)
    end

    local core_t = require('ad_idx.core')
    local core = core_t:new()
    local req_body={is_debug=false}
    core:run(req_body,post_body)
end

function ads_assign(ads_count,post_body)
    if tonumber(ads_count) < 5  then -- 增加配置
        post_body.strategy_products={'sfst'}
    else
        post_body.strategy_products={'wax'}
    end
end