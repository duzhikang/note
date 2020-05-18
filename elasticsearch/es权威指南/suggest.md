```
GET /wikinew/_search
{
  "query": {
    "match_all": {}
  }, 
  "suggest": {
    "text": "arest",
    "first_suggestion": {
      "term": {
        "field": "name"
      }
    },
    "second_suggest": {
      "term": {
        "field": "title"
      }
    }
  }
}

GET /wikinew/_search
{
  "suggest": {
    "first_sug": {
      "text": "chrimes in wordl",
      "term": {
        "field": "title"
      }
    },
    "secong_suggestion": {
      "text": "arest",
      "term": {
        "field": "text"
      }
    }
  }
}
```

# 1 term suggester

term suggester基于编辑距离来运作。这意味着，增删改某些字符转化为原词的改动越少，这个建议词就越有可能是最佳选择。

- text：这个选项代表希望从Elasticsearch得到建议的文本内容。这个选项是必需的，因为suggester有了它才能工作。
- field：这是另一个必备选项。这个选项允许指定要产生建议的字段。例如，如果仅希望从title字段的词项中产生建议，给本选项赋值为title。
- analyzer：这个选项指定分析器。分析器会把text参数中提供的文本切分成词项。如果不指定本选项的值，Elasticsearch会使用field参数所对应字段的分析器。
- size：这个选项指定针对text参数提供的词项，每个词项最多返回的建议词数量。默认值是5。
- sort：这个选项指定Elasticsearch给出的建议词的排序方式。默认值为score，表示先按建议词得分排序，再按文档频率排序，最后按词项本身排序。另一个可选值是frequency，表示先按文档频率排序，再按建议词得分排序，最后按词项本身排序。
- suggest_mode：这个选项用来控制什么样的建议词可以被返回。目前有3个可能的取值：missing、popular和always。默认值是missing，要求Elasticsearch对text参数的词项做一个区分对待，如果该词项不存在于索引中，则返回它的建议词，否则不返回。如果本选项的取值为popular，则要求Elasticsearch在生成建议词时做一个判断，如果建议词比原词更受欢迎（在更多文档中出现），则返回，否则不返回。最后一个可用的取值是always，意思是为text中的每个词都生成建议词。

## 2  phrase suggester

phrase suggester建立在termsuggester的基础之上, 返回完整的关于短语的建议.



## 3 completion suggester

它是一个基于前缀的suggester，可以用非常高效的方法实现自动完成（当在敲键盘时它就在搜索）的功能。

```
"suggest": {
          "type": "completion"
        }
PUT author
{
  "mappings": {
    "_doc": {
      "properties": {
      "author": {
        "properties": {
          "name": {
            "type": "keyword"
          },
          "suggest": {
            "type": "completion"
          }
        }
      }
    }
    }
  }
}

POST author/_doc/_search
{
  "suggest": {
    "sugsss": {
      "prefix": "fy",
      "completion": {
        "field": "author.suggest"
      }
    }
  }
}
POST author/_doc
{
  "author": {
    "name": "Fylers Jess",
    "suggest": {
      "input": ["fylers", "jess"]
    }
  }
}
# 模糊查询
POST author/_doc/_search
{
  "suggest": {
    "sugsss": {
      "prefix": "fyj",
      "completion": {
        "field": "author.suggest",
        "fuzzy": {
          "fuzziness": 2
        }
      }
    }
  }
}
```

词项频率（term frequency）将被基于前缀的suggester作为文档权重。

weight取值越大，建议项的重要性越大.(weight属性取值应该设置为整数)

completion suggester的另一个限制是不支持高级查询和过滤器。

# 4 实现自己的自动完成功能

基于n-grams实现一个定制的自动完成功能，可以胜任几乎所有的场景。

```
PUT locations
{
  "settings": {
    "index": {
      "analysis": {
      "filter": {
        "nGram_filter": {
          "token_chars": ["letter", "digit", "punctuation", "symbol", "whitespace"],
          "min_gram": "2",
          "type": "nGram",
          "max_gram": "20"
        }
      },
      "analyzer": {
        "nGram_analyzer": {
          "filter": ["lowercase", "asciifolding", "nGram_filter"],
          "type": "custom",
          "tokenizer": "whitespace"
        },
        "whitespace_analyzer": {
          "filter": ["lowercase", "asciifolding"],
          "type": "custom",
          "tokenizer": "whitespace"
        }
      }
    }
    }
  },
  "mappings": {
    "_doc": {
      "properties": {
        "name": {
          "type": "text",
          "analyzer": "nGram_analyzer",
          "search_analyzer": "whitespace_analyzer"
        },
        "country": {
          "type": "keyword"
        }
      }
    }
  }
}
#索引分析器 analyzer 搜索分析器   search_analyzer
POST locations/_doc/_bulk
{"index":{} }
{"name": "Liverpool", "country": "england"}
{"index":{} }
{"name": "San Diego Country Estates", "country": "usa"}
{"index":{} }
{"name": "Ike's Point, NJ", "country": "usa"}

POST locations/_search
{
  "query": {
    "match": {
      "name": "br"
    }
  }
}
```



# 5 处理同义词

```
PUT synonymsidx
{
  "settings": {
    "analysis": {
      "filter": {
        "my_synonyms_filter": {
          "type": "synonym",
          "synonyms": ["shares", "equity", "stock"]
        }
      },
      "analyzer": {
        "my_sysnonyms": {
          "filter": ["lowercase", "my_synonyms_filter"],
          "tokenizer": "standard"
        }
      }
    }
  }
}
在Elasticsearch的配置目录（通常是/etc/elasticsearch/）下创建名为synonyms.txt的文件，把这些同义词都写在文件里。
"my_synonyms_filter": {
    "type": "synonym",
    "synonyms_path": "synonyms.txt"
}
```

**请不要忘了将文件/etc/elasticsearch/synonyms.txt的属主改为用户Elasticsearch。**