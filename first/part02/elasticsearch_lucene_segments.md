# Elasticsearch、Lucene、Segments   
[分片内部原理](https://www.elastic.co/guide/cn/elasticsearch/guide/current/inside-a-shard.html)


## refresh  
默认值为1秒，即数据写入ES后1s可见。
```
"index.refresh_interval": "1s"
```
如果对数据的实时要求不高，可以增加refresh的频率，使indexBuffer中的数据积累的较多的时候，形成大的段（segment），这样可以减少大量小段合并，提升查询性能。

## segments

段合并是一项比较重的操作，会消耗大量磁盘IO；可以限制每个索引表合并线程数目，避免在写入高峰的时候有大量合并操作，影响写入性能
```
"index.merge.scheduler.max_merge_count": "200",
"index.merge.scheduler.max_thread_count": "1",
```

配置的源码位置  `org.elasticsearch.indexorg.elasticsearch.indexMergeSchedulerConfig`
```
 public static final Setting<Integer> MAX_THREAD_COUNT_SETTING =
        new Setting<>("index.merge.scheduler.max_thread_count",
            (s) -> Integer.toString(Math.max(1, Math.min(4, EsExecutors.allocatedProcessors(s) / 2))),
            (s) -> Setting.parseInt(s, 1, "index.merge.scheduler.max_thread_count"), Property.Dynamic,
            Property.IndexScope);
    public static final Setting<Integer> MAX_MERGE_COUNT_SETTING =
        new Setting<>("index.merge.scheduler.max_merge_count",
            (s) -> Integer.toString(MAX_THREAD_COUNT_SETTING.get(s) + 5),
            (s) -> Setting.parseInt(s, 1, "index.merge.scheduler.max_merge_count"), Property.Dynamic, Property.IndexScope);
    public static final Setting<Boolean> AUTO_THROTTLE_SETTING =
        Setting.boolSetting("index.merge.scheduler.auto_throttle", true, Property.Dynamic, Property.IndexScope);

```
### Stored Fields  
Stored Fields是一个简单的键值对key-value
默认情况下所有字段存储在_source字段下；
```
PUT elasticsearch-store-fields
{
   "mappings": {
      "_doc": {
         "properties": {
            "counter": {
               "type": "integer",
               "store": false       
            },
            "tags": {
               "type": "keyword",
               "store": true     
            }
         }
      }
   }
}
```

```
PUT elasticsearch-store-fields/_doc/1
{
    "counter" : 1,
    "tags" : ["red"]
}
```

```
GET elasticsearch-store-fields/_doc/1?stored_fields=tags,counter  
GET elasticsearch-store-fields/_search?stored_fields=tags,counter
```

###  Document Values  
以文件字段为单位进行列式存储；适用场景：排序、聚合、权重记分；




## translog
[官方文档](https://www.elastic.co/guide/en/elasticsearch/reference/6.4/index-modules-translog.html)
translog中的数据只有在fsync和提交时才会被持久化到磁盘。在硬件失败的情况下，在translog提交之前的数据都会丢失。
默认情况下，如果index.translog.durability被设置为async的话，Elasticsearch每5秒钟同步并提交一次translog。
或者如果被设置为request（默认）的话，每次index，delete，update，bulk请求时就同步一次translog。
更准确地说，如果设置为request, Elasticsearch只会在成功地在主分片和每个已分配的副本分片上fsync并提交translog之后，
才会向客户端报告index、delete、update、bulk成功。

可以动态控制每个索引的translog行为：   
 - index.translog.sync_interval  ：translog多久被同步到磁盘并提交一次。默认5秒。这个值不能小于100ms    
 - index.translog.durability  ：是否在每次index，delete，update，bulk请求之后立即同步并提交translog。接受下列参数：   
    - request  ：（默认）fsync and commit after every request。这就意味着，如果发生崩溃，那么所有只要是已经确认的写操作都已经被提交到磁盘。   
    - async  ：在后台每sync_interval时间进行一次fsync和commit。意味着如果发生崩溃，那么所有在上一次自动提交以后的已确认的写操作将会丢失。    
 - index.translog.flush_threshold_size  ：当操作达到多大时执行刷新，默认512mb。也就是说，操作在translog中不断累积，当达到这个阈值时，将会触发刷新(flush)操作。   
 - index.translog.retention.size  ：translog文件达到多大时执行执行刷新。默认512mb。   
 - index.translog.retention.age  ：translog最长多久提交一次。默认12h。    

translog-N.tlog  - 真正的日志文件，N表示generation（代）的意思，通过它跟索引文件关联
tranlog.ckp - 日志的元数据文件，长度总是20个字节，记录3个信息：偏移量 & 事务操作数量 & 当前代

例子
```
/elasticsearch/data/nodes/0/indices/gynPAM1CSeqeMHxAseKQSw/0/translog
```