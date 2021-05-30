# 简单搜索  
创建索引    
```
PUT cars
{
    "aliases": {},
    "mappings": {
      "_doc": {
        "properties": {
          "color": {
            "type": "text",
            "fields": {
              "keyword": {
                "type": "keyword",
                "ignore_above": 256
              }
            }
          },
          "make": {
            "type": "text",
            "fields": {
              "keyword": {
                "type": "keyword",
                "ignore_above": 256
              }
            }
          },
          "price": {
            "type": "long"
          },
          "sold": {
            "type": "date"
          }
        }
      }
    }
  }
```

插入数据   
```
POST /cars/_doc/_bulk
{ "index": {}}
{ "price" : 10000, "color" : "red", "make" : "honda", "sold" : "2014-10-28" }
{ "index": {}}
{ "price" : 20000, "color" : "red", "make" : "honda", "sold" : "2014-11-05" }
{ "index": {}}
{ "price" : 30000, "color" : "green", "make" : "ford", "sold" : "2014-05-18" }
{ "index": {}}
{ "price" : 15000, "color" : "blue", "make" : "toyota", "sold" : "2014-07-02" }
{ "index": {}}
{ "price" : 12000, "color" : "green", "make" : "toyota", "sold" : "2014-08-19" }
{ "index": {}}
{ "price" : 20000, "color" : "red", "make" : "honda", "sold" : "2014-11-05" }
{ "index": {}}
{ "price" : 80000, "color" : "red", "make" : "bmw", "sold" : "2014-01-01" }
{ "index": {}}
{ "price" : 25000, "color" : "blue", "make" : "ford", "sold" : "2014-02-12" }
```
## 轻量搜索   
[URI Search](https://www.elastic.co/guide/en/elasticsearch/reference/6.4/search-uri-request.html) 
[轻量搜索](https://www.elastic.co/guide/cn/elasticsearch/guide/current/search-lite.html)     
```
GET cars/_search?q=color:red
```
uri支持的参数  
  
| Name	  | 描述  | 
|  :----:  | :----:  |
| q | 对应Query DSL 的`query_string`,更多信息请参考[Query String Query](https://www.elastic.co/guide/en/elasticsearch/reference/6.4/query-dsl-query-string-query.html) |
| df |  数据库（Database）|
| analyzer |  一行数据（Row）|
| analyze_wildcard | 一列数据（Column） |
| 映射（mapping）| 数据库的组织和结构（Schema） |


