# 组合过滤查询  
[组合过滤器](https://www.elastic.co/guide/cn/elasticsearch/guide/current/combining-filters.html)  

## 布尔过滤  
一个 bool 过滤器由三部分组成：
```
{
   "bool" : {
      "must" :     [],
      "should" :   [],
      "must_not" : [],
   }
}
```
**must**   
所有的语句都 必须（must） 匹配，与 AND 等价。     
**must_not**   
所有的语句都 不能（must not） 匹配，与 NOT 等价。      
**should**   
至少有一个语句要匹配，与 OR 等价。   

```
GET /my_store/products/_search
{
   "query" : {
            "bool" : {
              "should" : [
                 { "term" : {"price" : 20}}, 
                 { "term" : {"productID.keyword" : "XHDK-A-1293-#fJ3"}} 
              ],
              "must_not" : {
                 "term" : {"price" : 30} 
              }
           }
         }
}

```
*嵌套查询*   

```
POST /_xpack/sql?format=txt
{
    "query": "SELECT * FROM my_store WHERE  productID.keyword  = 'KDKE-B-9947-#kL5' OR (productID.keyword = 'JODL-X-1937-#pV7' AND price = 30 )"
}
```

```
GET /my_store/_search
{
   "query" : {
            "bool" : {
              "should" : [
                { "term" : {"productID.keyword": "KDKE-B-9947-#kL5"}}, 
                { "bool" : { 
                  "must" : [
                    { "term" : {"productID.keyword": "JODL-X-1937-#pV7"}}, 
                    { "term" : {"price" : 30}} 
                  ]
                }}
              ]
           }
     }
}
```