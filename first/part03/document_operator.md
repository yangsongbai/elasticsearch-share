# 文档操作    

## 创建索引   

```
PUT operator_document_index-2021-05-31
{
    "aliases": {
      "operator_document_index-2021.05.31": {}
    },
    "mappings": {
      "log": {
        "dynamic": "true",
        "_all": {
          "enabled": false
        },
        "properties": {
           "time": {
            "type": "date"
          },
          "price": {
            "type": "long"
          },
          "productID": {
            "type": "text",
            "fields": {
              "keyword": {
                "type": "keyword",
                "ignore_above": 256
              }
            }
          }
        }
      }
    },
    "settings": {
      "index": {
        "mapping": {
          "total_fields": {
            "limit": "2000000"
          }
        },
        "refresh_interval": "20s",
        "indexing": {
          "slowlog": {
            "level": "info",
            "threshold": {
              "index": {
                "warn": "10s",
                "trace": "500ms",
                "debug": "2s",
                "info": "5s"
              }
            },
            "source": "1000"
          }
        },
        "translog": {
          "flush_threshold_size": "1024mb",
          "sync_interval": "120s",
          "durability": "async"
        },
        "max_result_window": "5000",
        "number_of_replicas": "0",
        "routing": {
          "allocation": {
            "exclude": {
              "zone": "data"
            },
            "total_shards_per_node": "1"
          }
        },
        "search": {
          "slowlog": {
            "level": "TRACE",
            "threshold": {
              "fetch": {
                "warn": "200ms",
                "trace": "200ms",
                "debug": "100ms",
                "info": "100ms"
              },
              "query": {
                "warn": "100ms",
                "trace": "200ms",
                "debug": "200ms",
                "info": "1s"
              }
            }
          }
        },
        "number_of_shards": "1",
        "merge": {
          "scheduler": {
            "max_thread_count": "1",
            "max_merge_count": "200"
          }
        }
      }
    }
  }
```

```
GET _cat/shards/operator_document_index-2021-05-31?v

PUT operator_document_index-2021-05-31/_settings
{
  "index":{
    "routing": {
          "allocation": {
            "exclude": {
              "zone": "client"
            },
            "total_shards_per_node": "1"
          }
        }
  }
}

```

## 索引文档   


## 获取文档   

