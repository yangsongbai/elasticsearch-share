# 分词器   

## 自定义分词 

```
PUT elasticsearch-analyzer-index
{
  "settings": {
    "analysis": {
      "analyzer": {
        "my_custom_analyzer": {
          "type": "custom",
          "char_filter": [
            "emoticons" ,
            "html_strip"
          ],
          "tokenizer": "punctuation", 
          "filter": [
            "lowercase",
            "english_stop",
            "asciifolding"
          ]
        }
      },
      "tokenizer": {
        "punctuation": { 
          "type": "pattern",
          "pattern": "[ .,!?。]"
        }
      },
      "char_filter": {
        "emoticons": { 
          "type": "mapping",
          "mappings": [
            ":) => _happy_",
            ":( => _sad_",
            "🐂 => 牛"
          ]
        }
      },
      "filter": {
        "english_stop": { 
          "type": "stop",
          "stopwords": "_english_"
        }
      }
    }
  },
  "mappings": {
      "_doc": {
        "properties": {
          "title": {
              "type": "text",
              "analyzer": "my_custom_analyzer",
              "search_analyzer": "my_custom_analyzer"
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
检测分词结果  
```
POST elasticsearch-analyzer-index/_analyze
{
  "analyzer": "my_custom_analyzer",
  "text":     "I'm a :) person, and you?<p>好未来🐂</p>"
}

POST elasticsearch-analyzer-index/_analyze
{
  "analyzer": "my_custom_analyzer",
  "text": "Is this <b>déjà vu</b>?"
}
```
响应结如下  
```
{
  "tokens": [
    {
      "token": "i'm",
      "start_offset": 0,
      "end_offset": 3,
      "type": "word",
      "position": 0
    },
    {
      "token": "_happy_",
      "start_offset": 6,
      "end_offset": 8,
      "type": "word",
      "position": 2
    },
    {
      "token": "person",
      "start_offset": 9,
      "end_offset": 15,
      "type": "word",
      "position": 3
    },
    {
      "token": "you",
      "start_offset": 21,
      "end_offset": 24,
      "type": "word",
      "position": 5
    },
    {
      "token": """

好未来牛

""",
      "start_offset": 25,
      "end_offset": 37,
      "type": "word",
      "position": 6
    }
  ]
}
```
插入数据   
```
POST elasticsearch-analyzer-index/_doc/1
{
  "title": "好未来 是一个以智慧教育和开放平台为主体，I'm a :) person, and you?<p>好未来🐂</p>。"
}

POST elasticsearch-analyzer-index/_doc/_bulk?refresh
{"index":{}}
{"author":"李四1" ,"title": "好未来是 一个 以 智慧教育 和 开放平台 为 主体。<b>好未来🐂</b>"}
{"index":{}}
{"author":"李四2" ,"title": "好未来 是 一个 以 智慧教育和 开放平台 为 主体，探索 未来 教育 新模式 的 科技教育 公司。"}
```
搜索
```
POST elasticsearch-analyzer-index/_search
{
  "query": {
    "match": {
       "title": "好未来牛"
    }
  }
}

POST elasticsearch-analyzer-index/_search
{
  "query": {
    "match": {
       "title": "好未来"
    }
  }
}

```

**官方文档**      
[analysis](https://www.elastic.co/guide/en/elasticsearch/reference/6.4/analysis.html)    

