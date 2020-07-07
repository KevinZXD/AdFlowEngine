# adFlowEngine
1. 基础的openrestyweb开发框架，适合流量网关，数据整合不落库的web项目，支持高并发

2. 广告流量引擎 包含广告流量统一估值管理模块（ad_uve），广告物料拼装(ad_render)，广告竞价模块(ad_idx)

[请求接口样例]

http://127.0.0.1:11111/ad_uve/service/mainfeed?uid=3898324509&from=1098493010&ad_counts=3

[返回样例]
单个广告数据

{
 "adtype": 8, //广告类型
 "id": "wax_ad_id_0",
 "product": "wax", //产品
 "ad_version": "1",
 "bid_price": 0.54892783198761, //竞价价格
 "ad_render": [
   "广告物料填充" //根据id单独获取广告物料数据按照指定的渲染类型渲染广告
                    ],
  "position": 0,
  "recommend": "广告",
  "type": "ad" // 广告类型 ad  trends
                }
                

[模块说明]
ad_uve
1. 广告流量管理
2. 广告样式控制/广告产品线控制
3. 广告渲染
 
ad_idx
1. 广告流量黑白名单过滤
2. 广告并行获取
3. 广告混合竞价

ad_render
1. 广告样式数据结构渲染

