# segment 合并相关参数释意

## 合并策略    

org.elasticsearch.index.MergePolicyConfig.java
```
 public static final double          DEFAULT_EXPUNGE_DELETES_ALLOWED     = 10d;
    public static final ByteSizeValue   DEFAULT_FLOOR_SEGMENT               = new ByteSizeValue(2, ByteSizeUnit.MB);
    public static final int             DEFAULT_MAX_MERGE_AT_ONCE           = 10;
    public static final int             DEFAULT_MAX_MERGE_AT_ONCE_EXPLICIT  = 30;
    public static final ByteSizeValue   DEFAULT_MAX_MERGED_SEGMENT          = new ByteSizeValue(5, ByteSizeUnit.GB);
    public static final double          DEFAULT_SEGMENTS_PER_TIER           = 10.0d;
    public static final double          DEFAULT_RECLAIM_DELETES_WEIGHT      = 2.0d;
    public static final Setting<Double> INDEX_COMPOUND_FORMAT_SETTING       =
        new Setting<>("index.compound_format", Double.toString(TieredMergePolicy.DEFAULT_NO_CFS_RATIO), MergePolicyConfig::parseNoCFSRatio,
            Property.Dynamic, Property.IndexScope);

    public static final Setting<Double> INDEX_MERGE_POLICY_EXPUNGE_DELETES_ALLOWED_SETTING =
        Setting.doubleSetting("index.merge.policy.expunge_deletes_allowed", DEFAULT_EXPUNGE_DELETES_ALLOWED, 0.0d,
            Property.Dynamic, Property.IndexScope);
    public static final Setting<ByteSizeValue> INDEX_MERGE_POLICY_FLOOR_SEGMENT_SETTING =
        Setting.byteSizeSetting("index.merge.policy.floor_segment", DEFAULT_FLOOR_SEGMENT,
            Property.Dynamic, Property.IndexScope);
    public static final Setting<Integer> INDEX_MERGE_POLICY_MAX_MERGE_AT_ONCE_SETTING =
        Setting.intSetting("index.merge.policy.max_merge_at_once", DEFAULT_MAX_MERGE_AT_ONCE, 2,
            Property.Dynamic, Property.IndexScope);
    public static final Setting<Integer> INDEX_MERGE_POLICY_MAX_MERGE_AT_ONCE_EXPLICIT_SETTING =
        Setting.intSetting("index.merge.policy.max_merge_at_once_explicit", DEFAULT_MAX_MERGE_AT_ONCE_EXPLICIT, 2,
            Property.Dynamic, Property.IndexScope);
    public static final Setting<ByteSizeValue> INDEX_MERGE_POLICY_MAX_MERGED_SEGMENT_SETTING =
        Setting.byteSizeSetting("index.merge.policy.max_merged_segment", DEFAULT_MAX_MERGED_SEGMENT,
            Property.Dynamic, Property.IndexScope);
    public static final Setting<Double> INDEX_MERGE_POLICY_SEGMENTS_PER_TIER_SETTING =
        Setting.doubleSetting("index.merge.policy.segments_per_tier", DEFAULT_SEGMENTS_PER_TIER, 2.0d,
            Property.Dynamic, Property.IndexScope);
    public static final Setting<Double> INDEX_MERGE_POLICY_RECLAIM_DELETES_WEIGHT_SETTING =
        Setting.doubleSetting("index.merge.policy.reclaim_deletes_weight", DEFAULT_RECLAIM_DELETES_WEIGHT, 0.0d,
            Property.Dynamic, Property.IndexScope);
```

```
 如果合并的段是小于总索引的此百分比，然后将其写在复合格式，否则它被写入以非复合格式, 
默认值0.1。该属性可用于系统出现文件句柄数量太多错误时使用，但是会降低搜索和索引的性能。
index.compound_format:  
index.merge.policy.expunge_deletes_allowed: 默认值为10，该值用于确定被删除文档的百分比，当执行expungeDeletes时，该参数值用于确定索引段是否被合并。
index.merge.policy.floor_segment:  默认2MB，小于该值的segment优先被合并
index.merge.policy.max_merge_at_once:  默认10,一次最多合并多少segment
index.merge.policy.max_merge_at_once_explicit: 默认30, 显式调用一次最多合并多少个segment
index.merge.policy.max_merged_segment:   默认5GB，超过该值的segment不合并
index.merge.policy.segments_per_tier:  每一轮merge的segment的允许数量。较小的值会导致较多的merge发生，但是最终的segment数目会较少。
默认是10.注意，这个值的设置要大于等于max_merge_at_once。否则将会导致太多merge发生。
index.merge.policy.reclaim_deletes_weight:  ;考虑merge的segment 时删除文档数量多少的权重，默认即可
默认值为2.0，该属性指定了删除文档在合并操作中的重要程度。如果属性值设置为0，删除文档对合并段的选择没有影响。其值越高，表示删除文档在对待合并段的选择影响越大。
```

## merge调度    
org.elasticsearch.inde.MergeSchedulerConfig  
```
public static final Setting<Integer> MAX_THREAD_COUNT_SETTING =
        new Setting<>("index.merge.scheduler.max_thread_count",
            (s) -> Integer.toString(Math.max(1, Math.min(4, EsExecutors.numberOfProcessors(s) / 2))),
            (s) -> Setting.parseInt(s, 1, "index.merge.scheduler.max_thread_count"), Property.Dynamic,
            Property.IndexScope);
    public static final Setting<Integer> MAX_MERGE_COUNT_SETTING =
        new Setting<>("index.merge.scheduler.max_merge_count",
            (s) -> Integer.toString(MAX_THREAD_COUNT_SETTING.get(s) + 5),
            (s) -> Setting.parseInt(s, 1, "index.merge.scheduler.max_merge_count"), Property.Dynamic, Property.IndexScope);
    public static final Setting<Boolean> AUTO_THROTTLE_SETTING =
        Setting.boolSetting("index.merge.scheduler.auto_throttle", true, Property.Dynamic, Property.IndexScope);

```

```
控制并发的merge线程数，如果存储是并发性能较好的SSD，可以用系统默认的max(1, min(4, availableProcessors / 2))，
当节点配置的cpu核数较高时，merge占用的资源可能会偏高，影响集群的性能，普通磁盘的话设为1
index.merge.scheduler.max_thread_count:

index.merge.scheduler.max_merge_count:
MAX_THREAD_COUNT_SETTING.get(s) + 5

index.merge.scheduler.auto_throttle: true

```

