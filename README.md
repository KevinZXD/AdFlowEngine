# adFlowEngine
1. 基础的openrestyweb开发框架，适合流量网关，数据整合不落库的web项目，支持高并发

2. 广告流量引擎 包含广告流量统一估值管理模块（ad_uve），广告物料拼装(ad_render)，广告竞价模块(ad_idx)

[请求接口样例]

http://127.0.0.1:11111/ad_uve/service/mainfeed?uid=3898324509&from=1098493010&ad_counts=3

[返回样例]

{
    "ad": [
        {
            "recommend": "热门",
            "id": "4523297448293259",
            "service": "mainfeed"
            "adtype": 8,
            "type": "ad",
            "product":"a",
            
            },
            
        {
                    "recommend": "广告",
                    "id": "4523297448293257",
                    "service": "mainfeed"
                    "adtype": 8,
                    "type": "ad",
                    "product":"a",
                    
                    }
                    
         {
                     "recommend": "推荐",
                     "id": "4523297448293254",
                     "service": "mainfeed"
                     "adtype": 8,
                     "type": "ad",
                     "product":"a",
                     
                     }
        
    ]
}
