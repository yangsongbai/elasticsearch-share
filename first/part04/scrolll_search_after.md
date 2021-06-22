# 分页查询     

插入数据
```
POST  page_search-2021-06-23/log/_bulk
{ "index": { "_id": 1 }}
{ "price" : 10, "productID" : "XHDK-A-1293-#fJ3","page" : 1,"time" : "2021-06-23" ,"title": "mac" }
{ "index": { "_id": 2 }}
{ "price" : 20, "productID" : "KDKE-B-9947-#kL5","page" : 2,"time" : "2021-06-23" ,"title": "mac" }
{ "index": { "_id": 3 }}
{ "price" : 30, "productID" : "JODL-X-1937-#pV7","page" : 3,"time" : "2021-06-23" ,"title": "mac" }
```
## scroll   
[scroll](https://www.elastic.co/guide/en/elasticsearch/reference/6.4/search-request-scroll.html)   
```
POST page_search-2021-06-23/_search?scroll=1m
{
    "size": 1,
    "query": {
        "match" : {
            "title" : "mac"
        }
    },
    "sort": [
    "_id"
  ]
}
```
scroll阶段   
```
POST /_search/scroll 
{
    "scroll" : "1m", 
    "scroll_id" : "首次search返回的scroll_id" 
}
```  

```
DELETE /_search/scroll/_all

DELETE /_search/scroll
{
    "scroll_id" : "DXF1ZXJ5QW5kRmV0Y2gBAAAAAAAAAD4WYm9laVYtZndUQlNsdDcwakFMNjU1QQ=="
}

DELETE /_search/scroll
{
    "scroll_id" : [
      "DXF1ZXJ5QW5kRmV0Y2gBAAAAAAAAAD4WYm9laVYtZndUQlNsdDcwakFMNjU1QQ==",
      "DnF1ZXJ5VGhlbkZldGNoBQAAAAAAAAABFmtSWWRRW"
    ]
}

DELETE /_search/scroll/DXlZkMWFBAAAAAAAAAAIWa1JZZFFZQmtTaj

```

## search_after   
[Search After](https://www.elastic.co/guide/en/elasticsearch/reference/6.4/search-request-search-after.html)    

````
POST page_search-2021-06-23/_search?scroll=1m
{
    "size": 1,
    "query": {
        "match" : {
            "title" : "mac"
        }
    },
    "sort": [
    "_id"
  ]
}
````
 
```
POST page_search-2021-06-23/_search
{
    "size": 1,
    "query": {
        "match" : {
            "title" : "mac"
        }
    },
    "sort": [
    "_id"
  ]
}
```  

```
POST page_search-2021-06-23/_search
{
    "size": 1,
    "query": {
        "match" : {
            "title" : "mac"
        }
    },
   "search_after": [1],
    "sort": [
        {"_id": "asc"}
    ]
}
```
