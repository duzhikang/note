# 1查询方式分类

## 1.1基本查询

- match查询：一种（实际上指好几种）查询方式，适用于执行全文检索且需要对输入进行分析的场景。

- match_all查询：这个查询匹配所有文档，常用于需要对所有索引内容进行归类处理的场景。

- term查询：一种简单的、无需对输入进行分析的查询方式

```
GET hotel/_search
{
  "query": {
    "term": {
      "name.keyword": {
        "value": "北京北京盛世公寓"
      }
    }
  }
}

GET hotel/_search
{
  "query": {
    "terms": {
      "name": ["盛世", "北京"]
    }
  }
}

GET hotel/_search
{
  "query": {
    "term": {
      "name": {
        "value": "盛世公寓"
      }
    }
  }
}

GET hotel/_search
{
  "query": {
    "match": {
      "name":  "盛世公寓gong"
    }
  }
}

GET hotel/_search
{
  "query": {
    "match_all": {
    }
  }
}
#term是代表完全匹配，即不进行分词器分析，文档中必须包含整个搜索的词汇
#match查询的时候,elasticsearch会根据你给定的字段提供合适的分析器,只包含其中一部分关键词就行,而term查询不会有分析器分析的过程
```

简单查询这一类可包括：`match、multi_match、common、fuzzy_like_this、fuzzy_like_this_field、geoshape、ids、match_all、query_string、simple_query_string、range、prefix、regexp、span_term、term、terms、wildcard`等。

## 1.2组合查询

组合查询的唯一用途是把其他查询组合在一起使用。**理论上我们可以把组合查询无穷次地嵌套，用来构建极其复杂的查询，唯一能够阻止这样嵌套的障碍是性能。**

组合查询:

- bool查询：最常用的组合查询方式之一。能够把多个查询用布尔逻辑组织在一起，可以控制查询的某个子查询部分是必须匹配、可以匹配还是不应该匹配。**希望文档的最终得分为所有子查询得分的和**。
- dis_max查询：一种非常有用的查询方式。**这种查询的文档得分结果和最高权重的子查询得分高度相关**，而不是如bool查询那样对所有子查询得分进行求和.

组合查询类别可包括这些查询方式：`bool、boosting、constant_score、dis_max、filtered、function_score、has_child、has_parent、indices、nested、span_first、span_multi、span_first、span_multi、span_near、span_not、span_or、span_term、top_children`等。

## 1.3.理解`bool`查询

Boolean从句可以组合起来，用于匹配文档:

- must：写在这个从句里面的条件必须匹配上，才能返回文档。
- should：写在should从句中的查询条件可能被匹配上，也可能不匹配，但如果bool查询中没有must从句，**那就至少要匹配上一个should条件**，文档才会返回。
- must_not：写在这个从句中的条件一定不能被匹配上。
- filter：写在这个从句中的查询条件必须被选中的文档匹配上，**只是这种匹配与评分无关**。

- boost：这个参数用于控制must或should查询从句的分数。
- minimum_should_match：这个参数只适用于should从句。有了它，就可以限定要返回一份文档的话，至少要匹配上多少个should从句。
- disable_coord：一般情况下，bool查询会对所有的should从句使用查询协调。这么做通常来说很好，因为匹配上的从句越多，文档的得分就越高。

```
POST hotel/_search 
{
  "query": {
    "bool": {
      "disable_coord": true,
      "must": [
        {"match": {
          "city_name": "北京市"
        }}
      ],
      "must_not": [
        {"match": {
          "area_name": "怀柔区"
        }}
      ]
    }
  }
}
# 加上disable_coord查询的数量不一样
```

## 1.4 无分析查询

有一类查询不会被分析，而是被**直接传递给Lucene索引。**

- term查询：即词项查询。当提及无分析查询时，最常用的无分析查询就是词项查询。它可

- prefix查询：即前缀查询。另一种无需分析的查询方式。

这类查询包括：`common、ids、prefix、span_term、term、terms、wildcard`等。

## 1.5 全文检索查询

本类的查询方式包括：`match、multi_match、query_string、simple_query_string`等。

## 1.6 模式匹配查询

比如通配符查询（wildcardquery），前缀查询（prefix query），正则表达式查询（regexpquery）

本类查询包括：`prefix、regexp、wildcard`等。

## 1.7 支持相似度操作的查询

属于这个类别的查询有：`fuzzy_like_this、fuzzy_like_this_field、fuzzy、more_like_this、more_like_this_field`等。

## 1.8 支持修改得分的查询

一组用于改善查询精度和相关度的查询方式，**通过指定自定义权重因子或提供额外处理逻辑的方式来改变文档得分**.

function_score查询可以使用函数，从而通过数学计算的方式改变文档得分。

本类查询包括：`boosting、constant_score、function_score、indices`等。

## 1.9 位置敏感查询

这是因为这些查询开销很大，需要消耗大量CPU资源才能保证正确处理。

本类查询包括：`match_phrase、span_first、span_multi、span_near、span_not、span_or、span_term`等。

## 1.10 结构敏感查询

这类查询包括：

-  nested查询。
- has_child查询。
- has_parent查询。
- top_children查询。

如果需要处理文档中的数据关系，请选择使用这类查询。



# 2 使用案例

```
1.查询给定范围的数据
GET hotel/_search
{
  "query": {
    "range": {
      "open_year": {
        "gte": 2018,
        "lte": 2019
      }
    }
  }
}

2.对多个词项的布尔查询
POST hotel/_search 
{
  "query": {
    "bool": {
      "should": [
        {"term": {"address": {"value": "北京"}}},
        {"term": {"address": {"value": "密云"}}},
        {"term": {"address": {"value": "二期"}}},
        {"term": {"address": {"value": "14号"}}}
    ],
    "minimum_should_match": "3<75%"
    }
  }
}
假设需求是用户要显示由查询条件决定的书的若干个标签。如果用户提供的标签数超过3个，
只要求匹配上查询条件中标签数的75%即可。如果用户提供了3个或更少的标签，就要全部匹配

3.对匹配文档加权
POST hotel/_search 
{
  "query": {
    "bool": {
      "must": [
        {"range": {"score": {"gte":4.4}}}
      ],
      "should": [
        {"range": {"open_year": {"gte": 2019}}}
      ]
    }
  }
}

4.忽略查询的较低得分部分
POST hotel/_search 
{
  "query": {
    "dis_max": {
      "tie_breaker": 0.0, 
      "queries": [
        {"range": {"score": {"gte":4.4}}},
        {"range": {"open_year": {"gte": 2019}}}
      ]
    }
  },
  "_source": false
}
dis_max查询返回的文档得分等于打分最高的查询片段的得分（上面的第一个查询片段）。这是因为把tie_breaker属性设置成了0.0。

5. 无分析查询示例
一般很少单独使用term查询，而是常常将其使用在各种复合查询中。

6. 全文检索查询示例
GET hotel/_search
{
  "query": {
    "query_string": {
      "query": "+name:北京 +name:公寓 +hotel_type:经济型"
    }
  }
}
GET hotel/_search
{
  "query": {
    "prefix": {
      "name": "北京"
    }
  }
}
GET hotel/_search
{
  "query": {
    "regexp": {
      "name": ".."
    }
  }
}

7.支持相似度操作的查询示例
GET hotel/_search
{
  "query": {
    "fuzzy": {
      "name": {
        "value": "北京真诚",
        "fuzziness": 0.0
      }
    }
  }
}
中文有问题
```

