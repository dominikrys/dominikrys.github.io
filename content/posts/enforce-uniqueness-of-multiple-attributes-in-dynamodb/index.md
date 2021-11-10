---
title: "How to Enforce Uniqueness of Multiple Attributes in DynamoDB"
date: 2021-10-31T09:53:52Z
ShowToc: true
cover:
    image: "img/cover.png"
    alt: "Cover"
tags:
  - dynamodb
  - databases
  - aws
  - software engineering
  - infrastructure
---

I've recently tried to solve a problem that involved enforcing uniqueness of multiple attributes in DynamoDB. Surprisingly, this wasn't a trivial undertaking. Given most of my database experience is using SQL databases, I initially started solving the problem using SQL paradigms that didn't translate well to NoSQL.

In this post, I will describe what I learned, and how it's possible to implement enforcing uniqueness of multiple attributes in DynamoDB.

## Approaches That Don't Work

### Using Condition Expressions

After some initial research, I tried implementing a Conditional Put using a [condition expression](https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/Expressions.ConditionExpressions.html#Expressions.ConditionExpressions.PreventingOverwrites). This seemed logical - add a condition expression with chained `attribute_not_exists(attribute_name)` statements and suddenly the database will start enforcing uniqueness of whichever combination of attributes I'd like.

Turns out that it doesn't work like that though. The reason being is that DynamoDB **evaluates condition expressions on at most one item in your table**. The item it compares against is found using the primary key, so by the time DynamoDB evaluates the condition expression, it's already not comparing against the attributes of the other items in the table.

Alex DeDrie's [post on DynamoDB Condition Expressions](https://www.alexdebrie.com/posts/dynamodb-condition-expressions/) explains this in more depth using helpful diagrams.

### Using a Secondary Index

Using a [secondary index](https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/SecondaryIndexes.html) that includes the attributes that you want to keep unique seems like another good idea. However, those can only be used for queries and can't be used as part of a condition in writes to your database (i.e. querying a secondary index and writing to your database can't happen atomically).

## Possible Solutions

I have to admit that the solutions to this problem may not be ideal for many use-cases. They either involve partitioning your database, changing the structure of its primary keys or entirely replacing the database with an RDS. Nevertheless, I will describe possible solutions below.

### Make up the Primary Key of the Attributes you want to Keep Unique

The partition key and sort key can be set to the attributes that you want to keep unique. If you have more than two attributes you'd like to maintain the uniqueness of, you can create a composite of them in either the partition or the sort key. Note that this only works for the case where you want to maintain the uniqueness of a **combination** of attributes.

There are some minor restrictions that come into play here, mostly in ensuring that the resulting partition and sort keys can be used for indexing the tables well. [AWS's guide on choosing partition keys](https://aws.amazon.com/blogs/database/choosing-the-right-dynamodb-partition-key/) can help in this case.

### Using Transactions

If you want to maintain the uniqueness of two separate attributes (i.e., not their combination), this approach could be your best bet. Using transactions entails creating an item from each attribute you want to keep unique and adding those items using a transaction. This works for maintaining the uniqueness of up to two attributes, however.

This solution comes with multiple caveats, however. One of the attributes effectively only becomes a marker for whether some value has already been inserted into the table - it can't be retrieved from the other attribute that is being kept unique, and vice-versa. It's possible to get around this, but it entails duplicating all attributes of the inserted item. This duplication will lead to increased costs of your writes and additional latency.

For a more in-depth explanation on this, including a code example, see [Alex Debrie's blog post on transactions](https://www.alexdebrie.com/posts/dynamodb-transactions/#maintaining-uniqueness-on-multiple-attributes).

### Replacing DynamoDB with an RDS

If you need to enforce uniqueness of multiple attributes, it may be the case that DynamoDB is not an ideal database system for your use case. Using an SQL database could be a better choice going forward, despite it being a substantial change to your codebase. If you found that you need to enforce uniqueness of multiple fields though, hopefully you're in the early days of your product's development. Since you're already using AWS, Amazon offers the [Amazon Relational Database Service](https://aws.amazon.com/rds/) that could work well here.
