# 去重统计   
[cardinality](https://www.elastic.co/guide/cn/elasticsearch/guide/current/cardinality.html)  
[cardinality-en](https://www.elastic.co/guide/en/elasticsearch/reference/6.4/search-aggregations-metrics-cardinality-aggregation.html)  
 
```
GET /cars/_doc/_search
{
    "size" : 0,
    "aggs" : {
        "distinct_colors" : {
            "cardinality" : {
              "field" : "color.keyword",
              "precision_threshold" : 100 
            }
        }
    }
}
#sql语句写法 
POST /_xpack/sql?format=txt
{
    "query": "SELECT COUNT(DISTINCT color.keyword) AS car_color FROM cars"
}
``` 