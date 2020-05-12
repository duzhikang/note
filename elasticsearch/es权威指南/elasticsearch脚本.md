# 1 语法

```
"script": {
    "inline": "doc['open_year'].value",
    "lang": "painless",
    "params": {}
}
```

- lang 参数定义脚本域名，默认painless
- inline|id|file参数指脚本自身，也可能写成inline、id或file。通过这种办法可以描述脚本的来源。内联的脚本可以写为inline，用id标记的存储脚本可以从集群中获取，文件脚本可以从config/scripts目录下的文件中获取。
- params参数为任意将被传入脚本的命名参数。

除了Painless，以下脚本语言仍被Elasticsearch直接支持：

- Lucene表达式，主要用于快速定制评分与排序。
- Mustache用于查询模板，已经在第2章中讨论过。
- Java，或者说是原生的脚本，用来写定制插件是最好的。

```
GET _search
{
  "query": {
    "function_score": {
      "query": {
        "match": {
          "name": "北京"
        }
      },
      "script_score": 
        {
          "script": {
            "inline": "def score = doc['score'].value; if (score < 1.0) {return 1.0} else if (score < 3.0) {return 5.0} else if (score < 4.0) {return 10.0} else if (score > 4.0) {return 20.0}",
            "lang": "painless"
          }
        }
    }
  },
   "_source": ["area_name", "score", "name"]
}
```

> **书写脚本注意空格。**



# 2 用脚本为结果排序

```
GET hotel/_search
{
  "query": {
    "match": {
      "name": "北京"
    }
  },
  "sort": 
    {
      "_script": {
        "type": "string",
        "order": "asc",
        "script": {
          "lang": "painless",
          "inline": "doc['area_name'].value"
        }
      }
    }
  ,"_source": ["area_name", "score", "name"],
  "size": 100
}

GET hotel/_search
{
  "query": {
    "match": {
      "name": "北京"
    }
  },
  "sort": 
    {
      "_script": {
        "type": "string",
        "order": "asc",
        "script": {
          "lang": "painless",
          "inline": "doc['city_name'].value +  doc['area_name'].value"
        }
      }
    }
  ,"_source": ["area_name", "score", "name"],
  "size": 100
}

```

如果想根据数字字段进行排序，**就要把script对象的type参数设置成number**。上面的查询根据tags字段的值将结果降序排列