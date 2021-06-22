# 搜索类型    

## query_then_fetch   


## dfs_query_then_fetch    


## 计算得分示例     

```
GET page_search-2021-06-23/log/2/_explain
{
  "query": {
    "match": {
      "productID": "KDKE"
    }
  }
}
```

返回值   
```
{
  "_index": "page_search-2021-06-23",
  "_type": "log",
  "_id": "2",
  "matched": true,
  "explanation": {
    "value": 0.2876821,
    "description": "weight(productID:kdke in 0) [PerFieldSimilarity], result of:",
    "details": [
      {
        "value": 0.2876821,
        "description": "score(doc=0,freq=1.0 = termFreq=1.0\n), product of:",
        "details": [
          {
            "value": 0.2876821,
            "description": "idf, computed as log(1 + (docCount - docFreq + 0.5) / (docFreq + 0.5)) from:",
            "details": [
              {
                "value": 1,
                "description": "docFreq",
                "details": []
              },
              {
                "value": 1,
                "description": "docCount",
                "details": []
              }
            ]
          },
          {
            "value": 1,
            "description": "tfNorm, computed as (freq * (k1 + 1)) / (freq + k1 * (1 - b + b * fieldLength / avgFieldLength)) from:",
            "details": [
              {
                "value": 1,
                "description": "termFreq=1.0",
                "details": []
              },
              {
                "value": 1.2,
                "description": "parameter k1",
                "details": []
              },
              {
                "value": 0.75,
                "description": "parameter b",
                "details": []
              },
              {
                "value": 4,
                "description": "avgFieldLength",
                "details": []
              },
              {
                "value": 4,
                "description": "fieldLength",
                "details": []
              }
            ]
          }
        ]
      }
    ]
  }
}
```