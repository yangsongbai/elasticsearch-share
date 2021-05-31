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

插入数据   ~~~~
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

GET cars/_search?q=color:red&analyzer=whitespace&df=make
```
uri支持的参数  
  
| Name	  | 描述  | 
|  :----:  | :----:  |
| q | 对应Query DSL 的`query_string`,更多信息请参考[Query String Query](https://www.elastic.co/guide/en/elasticsearch/reference/6.4/query-dsl-query-string-query.html) |
| df |  查询中未定义字段前缀时使用的默认字段 |
| analyzer | 分析查询字符串时要使用的分析器名称。 |
| analyze_wildcard | 是否应该分析通配符和前缀查询。默认为false。 |
| batched_reduce_size| 协调节点上应立即减少的碎片结果数.如果请求中可能存在大量shard，则应将此值用作保护机制，以减少每个搜索请求的内存开销。 |
| default_operator |  要使用的默认运算符可以是AND或OR。默认为OR。 |
| lenient | 如果设置为true，将导致忽略基于格式的失败（如向数字字段提供文本）。默认为false。 |
| explain | 对于每次命中，包含如何计算命中分数的说明。 |
| _source| 数据库的组织和结构（Schema） |
| stored_fields |  数据库（Database）|
| sort |  一行数据（Row）|
| track_scores | 一列数据（Column） |
| track_total_hits| 数据库的组织和结构（Schema） |
| lenient |  一行数据（Row）|
| explain | 一列数据（Column） |
| timeout| 数据库的组织和结构（Schema） |
| terminate_after |  数据库（Database）|
| from |  一行数据（Row）|
| size | 一列数据（Column） |
| search_type | 数据库的组织和结构（Schema） |
| allow_partial_search_results | 数据库的组织和结构（Schema） |

