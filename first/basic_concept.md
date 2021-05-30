# Elasticsearch基本概念  

## 集群（cluster）  
&emsp;&emsp; 一个Elasticsearch集群由一个或多个ES节点组成，并提供集群内所有节点的联合索引和搜索能力（所有节点共同存储数据）。       
&emsp;&emsp; 一个集群被命名为唯一的名字（默认为elasticsearch），集群名称非常重要，因为节点需要通过集群的名称加入集群。   
集群的的状态分为三种：`green`,`yellow`,`red`    
**green**  
&emsp;&emsp;集群所有索引的分片（shard）都被正常的分配到节点上；    
**yellow**  
&emsp;&emsp;集群中有索引存在副本分片（shard）没有被分配；   
**red**    
&emsp;&emsp;集群中有索引存在主分片（shard）没有被分配；   

查看集群健康信息  
```
GET _cluster/health?pretty
GET _cat/health?format=json
```
## 节点（node） 
&emsp;&emsp;一个节点是集群中的一个服务器，用来存储数据并参与集群的索引和搜索。    
和集群类似，节点由一个名称来标识，默认情况下，该名称是在节点启动时分配给节点的随机通用唯一标识符（UUID）。    
您也可以自定义任意节点的名称，节点名称对于管理工作很重要， 因为通过节点名称可以确定网络中的哪些服务器对应于Elasticsearch集群中的哪些节点。     
&emsp;&emsp;一个节点可以被添加到指定名称的集群中。默认情况下，每个节点会被设置加入到名称为elasticsearch的集群中， 
这意味着，如果在您在网络中启动了某些节点（假设这些节点可以发现彼此），它们会自动形成并加入名称为elasticsearch的集群中。        
&emsp;&emsp;一个集群可以拥有任意多的节点。此外，如果在您的网络中没有运行任何Elasticsearch节点， 此时启动一个节点会创建一个名称为elasticsearch的单节点集群。          

节点的角色可以，由以下三个参数来决定，不同角色，可以专注于完成不同的事：     
```
node.master: true
node.data: true
node.ingest：true
```
**Master Node(专有主节点)**       
如果节点为以下配置，则该节点为专有候选主节点；       
如果选举成功，则该节点成为master,master节点一般不用于和应用创建连接，每个节点都保存了集群状态，master节点不占用磁盘IO和CPU，内存使用量一般。        
其他没有选举成为master节点的，仍然保持候选主节点的身份，需要和占用的资源比master节点更少。       
```
# 具有资格选举成为主节点的，候选节点
node.master: true
node.data: false
node.ingest：false
```
master节点控制整个集群的元数据。只有Master Node节点可以修改节点状态信息及元数据(metadata)的处理，
比如索引的新增、删除、分片路由分配、所有索引和相关 Mapping 、Setting 配置等等。        

候选节点：与集群保持心跳，判断Master是否存活，如果Master故障则参加新一轮的Master选举      

集群规划 ： Elasticsearch集群建议master至少三台(生产建议每个es实例部署在不同的设备上)，      
三个Master节点最多只能故障一台Master节点，数据不会丢失，如果三个节点故障两个节点，则造成数据丢失并无法组成集群。     

**Data Node(专有数据节点)**        
数据节点，该节点和索引应用创建连接、接收索引请求，该节点真正存储数据，ES集群的性能取决于该节点的个数（每个节点最优配置的情况下），data节点会占用**大量的CPU、IO和内存**。      
 
data节点的分片执行查询语句获得查询结果后将结果反馈给协调节点，在查询的过程中非常消耗硬件资源，如果在分片配置及优化没做好的情况下,
进行一次查询非常缓慢(硬件配置也要跟上数据量)。     

在Elasticsearch集群中，此节点应该是最多的，单个索引在一个data节点实例上分片数保持在3个以内(建议分片数量按照Data节点数量划分比较好，每个节点上存储一个分片)；    
每1GB堆内存对应集群的分片保持在20个以内；每个分片大小不要超过30G，纯搜索型建议不超过10GB，日志型建议30GB-50GB。    

```
node.master: false
node.data: true
node.ingest：false
```

内存建议:
假如一台机器部署了一个ES实例，则ES最大可用内存给到物理内存的50%，最多不可超过32G（如果超过32GB，jvm将会使用长指针，官方建议堆内存分配为26-32GB）。
如果单台机器上部署了多个ES实例，则多个ES实例内存相加等于物理内存的50%，多个ES实例内存相加不宜超过32G。

分片建议（理想情况下）：  
如果单个分片每个节点可支撑90G数据，依此可计算出所需data节点数。   
如果多个分片按照单个data节点jvm内存最大30G来计算，一个节点的分片保持在600个以内，存储保持在18T以内。       

**Ingest Node(专有数据预处理节点)**        
ingest 节点可以看作是数据前置处理转换的节点，支持 pipeline管道 设置，可以使用 ingest 对数据进行过滤、转换等操作，类似于 logstash 中 filter 的作用，功能相当强大。   

Ingest节点处理时机——在数据被索引之前，通过预定义好的处理管道对数据进行预处理。默认情况下，所有节点都启用Ingest，因此任何节点都可以处理Ingest任务。我们也可以创建专用的Ingest节点。 

通常数据的加工建议，放在专有的数据 ETL组件中     
```
node.master: false
node.data: false
node.ingest：true
```
**Coordinating Node(专有协调节点)**       
协调节点，该节点和检索应用创建连接、接受检索请求，但其本身不负责存储数据，可当负责均衡节点，该节点不占用io、cpu和内存。但是如果有不合理的聚合查询，也会导致协调节点oom。  

协调节点接受客户端搜索请求后将请求转发到与查询条件相关的多个data节点的分片上，然后多个data节点的分片执行查询语句或者查询结果再返回给协调节点，协调节点把各个data节点的返回结果进行整合、排序等一系列操作后再将最终结果返回给用户请求

增加协调节点可增加检索并发,但检索的速度还是取决于查询所命中的分片个数以及分片中的数据量   
```
node.master: false
node.data: false
node.ingest：false
```

查看节点信息
```
GET _cat/nodes?v&format=txt
```

## 索引（index）  
&emsp;&emsp;一个索引是一个拥有一些相似特征的文档的集合（相当于关系型数据库中的一个数据库）。
例如，您可以拥有一个客户数据的索引，以及一个订单数据的索引。
一个索引通常使用一个名称（所有字母必须小写）来标识，
当针对这个索引的文档执行索引、搜索、更新和删除操作的时候，这个名称被用来指向索引。
> 表 1-1 Elasticsearch与关系型数据库的对应关系  

| Elasticsearch	  | 关系型数据库  | 
|  :----:  | :----:  |
| 索引（index）|  HTTP方法，包括`GET`、`POST`、`PUT`、`HEAD`、`DELETE`。|
| 文档类型（type），es6版本之后一个index只能有一个type|  数据库（Database）|
| 文档（document）|  一行数据（Row）|
| 字段（field）| 一列数据（Column） |
| 映射（mapping）| 数据库的组织和结构（Schema） |

&emsp;&emsp;在Elasticsearch中索引一词，有多种含义：
>Index Versus 
>>&emsp;&emsp;你也许已经注意到 索引 这个词在 Elasticsearch 语境中有多种含义， 这里有必要做一些说明：    
  **索引（名词）：**       
&emsp;&emsp;如前所述，一个 索引 类似于传统关系数据库中的一个 数据库 ，是一个存储关系型文档的地方。
索引 (index) 的复数词为 `indices` 或 `indexes` 。
>>**索引（动词）：**       
&emsp;&emsp;索引一个文档 就是存储一个文档到一个 索引 （名词）中以便被检索和查询。
这非常类似于 SQL 语句中的 `INSERT` 关键词，除了文档已存在时，新文档会替换旧文档情况之外。
>>**倒排索引**：          
&emsp;&emsp;关系型数据库通过增加一个 索引 比如一个 `B树`（B-tree）索引 到指定的列上，
以便提升数据检索速度。`Elasticsearch` 和 `Lucene` 使用了一个叫做 倒排索引 的结构来达到相同的目的。
>>&emsp;&emsp;默认的，一个文档中的每一个属性都是 被索引 的（有一个倒排索引）和可搜索的。 
一个没有倒排索引的属性是不能被搜索到的。

索引的状态分为三种：`green`,`yellow`,`red`  
**green**  
&emsp;&emsp;索引的分片（shard）都被正常的分配到节点上；    
**yellow**     
&emsp;&emsp;索引存在副本分片（shard）没有被分配；      
**red**    
&emsp;&emsp;索引存在主分片（shard）没有被分配； 
## 类型（type）
&emsp;&emsp;一个类型通常是一个索引的一个逻辑分类或分区，允许在一个索引下存储不同类型的文档（相当于关系型数据库中的一张表）
，例如用户类型、订单类型等。目前已经不支持在一个索引下创建多个类型，并且类型概念已经在后续版本中删除，
详情请参见[Elasticsearch官方文档](https://www.elastic.co/guide/en/elasticsearch/reference/current/removal-of-types.html )。

## 文档（document）
&emsp;&emsp;`Elasticsearch` 是 面向文档 的，意味着它存储整个对象或 文档。`Elasticsearch` 不仅存储文档，
而且 索引 每个文档的内容， 
使之可以被检索。在 `Elasticsearch` 中，我们对文档进行索引、检索、排序和过滤—​而不是对行列数据。
这是一种完全不同的思考数据的方式，也是 `Elasticsearch` 能支持复杂全文检索的原因。   

如果我们知道一个文档的id，那么我们可以通过以下语句直接改文档   
```
GET elasticsearch_study_index/_doc/1
```
##  字段（field）  
&emsp;&emsp;组成文档的最小单位。相当于关系型数据库中的一列数据。   
## 映射（mapping）  
&emsp;&emsp;用来定义一个文档以及其所包含的字段如何被存储和索引，
例如在`mapping`中定义字段的名称和类型，以及所使用的分词器。相当于关系型数据库中的`Schema`。

## 分片（shards）  
&emsp;&emsp;代表索引分片，`Elasticsearch`可以把一个完整的索引分成多个分片,即一个索引表其实是一组`shard`的逻辑视图，
这样的好处是可以把一个大的索引拆分成多个，分布到不同的节点上，构成分布式搜索。
分片的数量只能在索引创建前指定，并且索引创建后不能更改。

## 段（segements）
每个shard分片是一个lucene实例，每个分片由多个segment组成。每个segment占用内存，文件句柄等。   
服务器总内存除了分配jvm配置的，其余都给了lucene，占用page cache内存，page cache保存对文件数据segment的缓存。free -g可查看内存使用，es节点只有es服务，基本cache就是缓存的segment
```
#查看集群所有索引segements的情况
GET _cat/segments?v
#查看每个节点segements占用的堆内存
GET _cat/nodes?v&h=ip,ram.percent,sm
#查看指定索引的segements的情况
GET _cat/segments/elasticsearch_study_index?v
```