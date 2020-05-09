# 入门

## 面向文档

Elasticsearch是**面向文档(document oriented)**的，这意味着它可以存储整个对象或**文档(document)**。然而它不仅仅是存储，还会**索引(index)**每个文档的内容使之可以被搜索。

## 索引

在Elasticsearch中存储数据的行为就叫做**索引(indexing)**。

在Elasticsearch中，文档归属于一种**类型(type)**,而这些类型存在于**索引(index)**中，我们可以画一些简单的对比图来类比传统关系型数据库。（在6.0中索引的mapping不支持多个类型：每个索引具有多个映射类型的特性已在6.0中移除。新索引将限制为单个类型。在5.x中创建的索引将继续支持多种映射类型。es7中使用默认的_doc作为type，官方说在8.x版本会彻底移除type。）

```
Relational DB -> Databases -> Tables -> Rows -> Columns
Elasticsearch -> Indices   -> Types  -> Documents -> Fields
```

es7的java代码，只能使用restclient。然后，个人综合了一下，对于java编程，建议采用 High-level-rest-client 的方式操作ES集群

> ### 「索引」含义的区分
>
> 你可能已经注意到**索引(index)**这个词在Elasticsearch中有着不同的含义，所以有必要在此做一下区分:
>
> - 索引（名词） 如上文所述，一个**索引(index)**就像是传统关系数据库中的**数据库**，它是相关文档存储的地方，index的复数是**indices** 或**indexes**。
> - 索引（动词） **「索引一个文档」**表示把一个文档存储到**索引（名词）**里，以便它可以被检索或者查询。这很像SQL中的`INSERT`关键字，差别是，如果文档已经存在，新的文档将覆盖旧的文档。
> - 倒排索引 传统数据库为特定列增加一个索引，例如B-Tree索引来加速检索。Elasticsearch和Lucene使用一种叫做**倒排索引(inverted index)**的数据结构来达到相同目的。

默认情况下，文档中的所有字段都会被**索引**（拥有一个倒排索引），只有这样他们才是可被搜索的。

## 检索文档

```Jacscript
GET /{索引名称}/{type}/{id}
简单搜索
GET /{索引名称}/{type}/_search
DSL语句查询
GET /{索引名称}/{type}/_search
{
    "query" : {
        "match" : {
            "last_name" : "Smith"
        }
    }
}
更复杂的搜索
GET /megacorp/employee/_search
{
    "query" : {
        "filtered" : {
            "filter" : {
                "range" : {
                    "age" : { "gt" : 30 } <1>
                }
            },
            "query" : {
                "match" : {
                    "last_name" : "smith" <2>
                }
            }
        }
    }
}
全文搜索
GET /megacorp/employee/_search
{
    "query" : {
        "match" : {
            "about" : "rock climbing"
        }
    }
}
```

 Elasticsearch有一个功能叫做**聚合(aggregations)**，它允许你在数据上生成复杂的分析统计。它很像SQL中的`GROUP BY`但是功能更强大。