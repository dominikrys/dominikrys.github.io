---
title: "Caveats to Creating Datadog Log Metrics in Terraform"
date: 2021-11-14T9:52:58Z
ShowToc: true
cover:
    image: "img/cover.png"
    alt: "Cover"
tags:
  - DataDog
  - Terraform
  - SRE
---

In this post, I give an overview of how to create Datadog Log Metrics in Terraform. Having had done this recently, I encountered a couple of caveats that warranted documenting. Hopefully it will help others that encountered similar issues.

This post assumes that you have a basic configuration for Datadog in Terraform already. If you don't, [Datadog's post on managing Datadog with Terraform](https://www.datadoghq.com/blog/managing-datadog-with-terraform/) is a good starting point.

## Datadog Terraform Resources

There are three Terraform resources that you can use to configure log metrics in Datadog:

- [`datadog_logs_metric`](https://registry.terraform.io/providers/DataDog/datadog/latest/docs/resources/logs_metric) - used to create a custom log metric.
- [`datadog_metric_metadata`](https://registry.terraform.io/providers/DataDog/datadog/latest/docs/resources/metric_metadata) - used to modify metric metadata.
- [`datadog_metric_tag_configuration`](https://registry.terraform.io/providers/DataDog/datadog/latest/docs/resources/metric_tag_configuration) - used to modify metric tag configurations. **This can also be used to include percentiles for your metric**.

Most of the configuration for these is self-explanatory, so I won't go in-depth into every detail. However, some additional steps are not particularly well documented, which I will describe below.

## Facets and Measures for Metric Aggregation

The `path` value under `compute` of the `datadog_logs_metric` resource is the path to the value that the metric will aggregate on. This value can be a [facet or a measure](https://docs.datadoghq.com/logs/explorer/facets/). Facets are used for qualitative values, and measures are used for quantitative values. For the metric to correctly aggregate on a log field, **you need to create a measure or a facet for the log field**.

Ideally, facets and measures would be able to be created using Terraform, but that's not yet possible. There is [an open GitHub issue](https://github.com/DataDog/terraform-provider-datadog/issues/225) which tracks this feature's progress. In the meantime, we will need to create measures and facets in the Datadog UI. In production workflows, it's worth documenting this manual step.

### Creating Facets and Measures

1. Go to the [Datadog Log Explorer](https://app.datadoghq.eu/logs).

2. Filter and find a log entry that contains the field whose value you want your custom metric to aggregate on.

3. Hover over the log field and click on the cog icon that appears.

    {{< figure src="img/cog_labelled.png" alt="Cog Icon Next to Log Field" align="center" >}}

4. Select if you want to create a measure or a facet from the log field.

    {{< figure src="img/facet_menu_labelled.png" alt="Facet and Measure Menu" align="center" >}}

## Modifying Metric Metadata

When modifying metric metadata using the `datadog_metric_metadata` resource, you may find that your `terraform apply` operations fail, despite `terraform plan` succeeding. This may be because **you can't modify the metadata of a metric that has not yet recorded any data**. This could happen if you freshly create a metric, or if you rename a metric and Datadog doesn't yet receive any data to record in it.

### Iterating on Metric Metadata Changes

To remedy the above issue, I followed a simple regime while iterating on my metric metadata changes:

1. Create your metric (either using the Datadog UI or `terraform apply`). Make sure it's visible on the [Datadog Generate Metrics page](https://app.datadoghq.eu/logs/pipelines/generate-metrics).

2. Search for your metric under [the Datadog metric summary page](https://app.datadoghq.eu/metric/summary). It won't appear at first, but leave this page open for the next step.

3. Interact with your system in such a way that the metric records some data. Eventually, you will find that your metric shows up on the metric summary page. Note that this may take up to 10 minutes.

4. Apply your Terraform changes that include your metric metadata modifications. It should now succeed.

## Refactoring Tips

If you've created multiple metrics that refer to a similar concept, you may find yourself duplicating your resource declarations and only changing parts of certain fields. To help with refactoring this, you could store the parts that differ (e.g. the metric and field names) in a Terraform string set [variable](https://www.terraform.io/docs/language/values/variables.html) and substituting the names in your resources using a [`for_each` meta-argument](https://www.terraform.io/docs/language/meta-arguments/for_each.html).
