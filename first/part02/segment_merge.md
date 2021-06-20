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
index.compound_format:
index.merge.policy.expunge_deletes_allowed:
index.merge.policy.floor_segment:
index.merge.policy.max_merge_at_once:
index.merge.policy.max_merge_at_once_explicit:
index.merge.policy.max_merged_segment:
index.merge.policy.segments_per_tier:
index.merge.policy.reclaim_deletes_weight:

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
index.merge.scheduler.max_thread_count:
Math.max(1, Math.min(4, 配置的可使用CPU数/ 2))

index.merge.scheduler.max_merge_count:
MAX_THREAD_COUNT_SETTING.get(s) + 5

index.merge.scheduler.auto_throttle: true

```