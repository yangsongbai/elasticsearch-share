# 第一期走近Elasticsearch 
因为演示的ES集群只有一个节点，所以设置一个模板，所有索引不设置副本  
```
PUT _template/all-index
{
    "order": 0,
    "index_patterns": [
      "*"
    ],
    "settings": {
      "index": {
        "number_of_shards": "1",
        "auto_expand_replicas": "0-1",
        "number_of_replicas": "0"
      }
    }
}
```
## 倒排索引在elasticsearch中的简单应用  

```
PUT elasticsearch_study_index
{
    "aliases": {},
    "mappings": {
      "_doc": {
        "properties": {
          "title": {
              "type": "text",
              "analyzer": "whitespace"
          },
          "author":{
              "type": "keyword",
             "ignore_above": 256
          },
          "content": {
            "type": "text",
            "fields": {
              "space": {
                "type": "text",
                "analyzer": "whitespace"
              }
            }
          },
          "descripe": {
            "type": "text",
            "analyzer": "standard"
          }
        }
      }
    }
  }
```
插入一条数据
```
POST elasticsearch_study_index/_doc/1
{
  "title": "好未来 是一个以智慧教育和开放平台为主体，探索未来教育新模式的科技教育公司。"
}
```
对数据进行搜索
```
#搜索不到数据
GET elasticsearch_study_index/_search
{
  "query": {
    "match": {
      "title": "好未"
    }
  }
}
# 能够搜索数据
GET elasticsearch_study_index/_search
{
  "query": {
    "match": {
      "title": "好未来"
    }
  }
}
```
查看`whitespace`分词结果  
```
POST elasticsearch_study_index/_analyze
{
  "analyzer": "whitespace",
  "text": "好未来 是一个以智慧教育和开放平台为主体，探索未来教育新模式的科技教育公司。"
}
```
