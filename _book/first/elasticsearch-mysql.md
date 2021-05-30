# Elasticsearch 与 mysql   

## 轻量查询  
批量插入数据   
```
POST elasticsearch_study_index/_doc/_bulk
{"index":{}}
{"author":"张三2" ,"title": "好未来 是一个以智慧教育和开放平台为主体，探索未来教育新模式的科技教育公司。"}
{"index":{}}
{"author":"张三3" ,"title": "好未来 是 一个 以 智慧教育和 开放平台 为 主体，探索 未来 教育 新模式 的 科技教育 公司。"}

```
*简单查询*   
[轻量搜索](https://www.elastic.co/guide/cn/elasticsearch/guide/current/search-lite.html)   
```

```

