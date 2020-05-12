Lucene表达式是一个非常强大的工具，无需写Java代码就可以轻松地调整分数。Lucene表达式吸引人之处在于**执行速度非常快**，甚至与原生脚本一样快，因为每个表达式都被编辑成了Java字节码来获得与原生代码一样的性能。

Lucene表达式可以使用在Elasticsearch的下面这些功能中：

- 用于排序的脚本。

- 数值字段中的聚合。
- script_score查询中的function_score查询。
- 使用script_fields的查询。

注意：

- Lucene表达式仅能在数值字段上使用。
- Lucene表达式不能访问存储字段（stored field）。
- 没有为字段提供值时，会使用数值0。
- 可使用_score访问文档得分，可以使用doc['field_name'].value访问文档的单值数值字段中的值。
- Lucene表达式中不允许使用循环，只能使用单条语句。

```
GET hotel/_search
{
  "query": {
    "function_score": {
      "query": {
        "match": {
          "city_name": "北京市"
        }
      },
      "script_score": {
        "script": {
          "lang": "expression",
          "inline": "_score + doc['score'].value*per",
          "params": {
            "per": 10
          }
        }
      }
    }
  }
  ,"_source": ["area_name", "score", "name"],
  "size": 100
}
```

