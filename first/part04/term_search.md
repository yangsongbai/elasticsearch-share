# 精准值查询  
[精确值查找](https://www.elastic.co/guide/cn/elasticsearch/guide/current/_finding_exact_values.html)
[Term相关查询](https://www.elastic.co/guide/en/elasticsearch/reference/6.4/term-level-queries.html)  
```
POST /my_store/products/_bulk
{ "index": { "_id": 1 }}
{ "price" : 10, "productID" : "XHDK-A-1293-#fJ3" }
{ "index": { "_id": 2 }}
{ "price" : 20, "productID" : "KDKE-B-9947-#kL5" }
{ "index": { "_id": 3 }}
{ "price" : 30, "productID" : "JODL-X-1937-#pV7" }
{ "index": { "_id": 4 }}
{ "price" : 30, "productID" : "QQPX-R-3956-#aD8" }
```
**数字精确查询**  
```
GET /my_store/products/_search
{
    "query" : {
        "constant_score" : { 
            "filter" : {
                "term" : { 
                    "price" : 20
                }
            }
        }
    }
}

POST /_xpack/sql?format=txt
{
    "query": "SELECT * FROM  my_store WHERE  price = 20"
}

```

**文本精确查询**   
```
GET /my_store/products/_search
{
    "query" : {
        "constant_score" : {
            "filter" : {
                "term" : {
                    "productID.keyword": "XHDK-A-1293-#fJ3"
                }
            }
        }
    }
}

# 查看报错,xpack插件对sql支持的不是特别好 
POST /_xpack/sql?format=txt
{
    "query": "SELECT * FROM  my_store WHERE  productID.keyword = 'XHDK-A-1293-#fJ3'"
}
```

