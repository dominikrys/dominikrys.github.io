---
title: "Automatically Generating a Grafana Agent Configuration for a Kubernetes Cluster"
date: 2022-03-30T21:37:36+01:00
ShowToc: true
searchHidden: false
cover:
    image: "img/cover.png"
    alt: "Cover"
tags:
  - Kubernetes
  - Grafana
  - Observability
  - Site Reliability Engineering
---

Configuring the [Grafana Agent](https://github.com/grafana/agent/) to collect metrics from nodes in a Kubernetes cluster can be quite a daunting task. Manually configuring scrape jobs for all the pods running in your cluster can be a laborious undertaking that is not maintainable in the long run, especially as new services are added. In this post, I describe a way to generate a Grafana Agent configuration for a Kubernetes cluster using the Grafana Agent Operator.

## Possible Solutions

The easiest way to manage Grafana Agent deployments is using the [Grafana Agent Operator](https://grafana.com/docs/agent/latest/operator/). The operator dynamically spins up Grafana Agents as they're needed and generates a configuration for them using custom resources that you configure. The custom resources find [PodMonitors](https://github.com/prometheus-operator/prometheus-operator/blob/main/Documentation/api.md#podmonitor), [ServiceMonitors](https://github.com/prometheus-operator/prometheus-operator/blob/main/Documentation/api.md#servicemonitor) and [Probes](https://github.com/prometheus-operator/prometheus-operator/blob/main/Documentation/api.md#probe) that are running in your cluster.

The operator has a couple of shortcomings that make its use prohibitive for some use cases, however:

- It can't be [configured to run Grafana Agents as a DaemonSet](https://github.com/grafana/agent/issues/1495), which may be important for some use cases, especially if memory usage is an issue.
- Much of the generated configuration can't be altered, unless the operator's source code is modified.
- [It currently doesn't support traces](https://github.com/grafana/agent/issues/1044).
- It's currently in beta, so it may not be suited for every production use case.

## Operator Config Generation

Despite its shortcomings, the operator is very good at two things - service discovery and Grafana Agent configuration generation. Below, I'll describe how to use the operator to generate the configuration for a cluster and extract it. The configuration can then be used in ordinary Grafana Agent deployments in Kubernetes, allowing you to modify the configuration and agent deployments in any way you like. For more information on how to configure Grafana Agents outside of the Grafana Agent Operator, check the [Grafana Agent Kubernetes docs](https://grafana.com/docs/grafana-cloud/kubernetes/agent-k8s/k8s_agent_metrics/).

There's a downside to this solution, however. If new PodMonitors, ServiceMonitors, or Probes are added, **the operator will need to be run again** to pick up the changes and generate a new configuration. This may not need to happen often though, and if needed, the entire configuration-generation process can be scripted and automated.

## Extracting the Agent Configuration from the Grafana Operator

1. Install the Grafana Agent Operator into your cluster by following [the documentation](https://grafana.com/docs/agent/latest/operator/getting-started/). The default configuration doesn't need to be modified, although I'd recommend **deploying the operator in a new namespace**. A new namespace will allow you to remove the operator and its associated custom resources easily once the config generation is done.

    To create a new namespace in your Kubernetes cluster (using the namespace name `grafana-temp` as an example), run:

    ```bash
    kubectl create namespace grafana-temp
    ```

    Then, replace all references of `namespace: default` in the operator configuration with `namespace: grafana-temp`. Finally, apply the configuration:

    ```bash
    kubectl -n grafana-temp apply -f production/operator/crds
    ```

2. Set up `GrafanaAgent` and `MetricsInstance` custom resources by following [the documentation](https://grafana.com/docs/agent/latest/operator/custom-resource-quickstart/). Some small modifications will be needed, but first, it's worth understanding how these resources work.

    Effectively, the Grafana Agent Operator discovers `GrafanaAgent` resources. `GrafanaAgent` resources are configured to discover `MetricsInstance` resources. The `MetricsInstance` resources will discover PodMonitors, ServiceMonitors, and probes which will be used to generate an agent configuration.

    The necessary modifications are:

    - Change the namespace from `default` to `grafana-temp` under the `metadata` key of each deployment if you deployed the operator in a separate namespace. **Don't** set this namespace anywhere else in the file (we'll get to that in the next step). Likewise, use the `-n grafana-temp` flag in the `kubectl apply` command when applying changes as in the previous step.

    - In the `MetricsInstance`, configure which ServiceMonitors, PodMonitors, and probes the operator should discover.

    - Changing the remote write URL to any valid URL. You can enter your Prometheus instance's details in the configuration, but it's not necessary. The operator will be able to run and generate an agent configuration even if the Prometheus details are invalid.

3. Verify that the operator and its deployed pods are running and haven't returned any errors.

    This can be done by checking the pods in the `grafana-temp` namespace that we defined earlier, or by searching for pods with `grafana` in their name. Personally, I used [k9s](https://k9scli.io/) to check the pods. Make any necessary changes if the pods are unhealthy to the operator config and re-apply it by running the relevant `kubectl` command again. The operator will automatically pick up any changes.

4. Dump the generated Grafana Agent config to disk:

    ```bash
    kubectl get secret -n grafana-temp grafana-agent-config -o json | jq '.data' | cut -d '"' -f 4 | tr -d '{}' | base64 --decode > config-metrics.yaml
    ```

5. If you created the temporary namespace earlier, you can delete it:

    ```bash
    kubectl delete namespace grafana-temp
    ```

6. Make small modifications to the generated config:

    - Remove the sharding configuration in every scrape job which is added as of v0.23 of the Grafana Agent Operator. It makes the metrics not be sent when used by an agent running outside of the operator:

    ```yaml
                - action: hashmod
                  modulus: 1
                  source_labels:
                    - __address__
                  target_label: __tmp_hash
                - action: keep
                  regex: $(SHARD)
                  source_labels:
                    - __tmp_hash
    ```

    - Tweak any other values in the config apart from under the `scrape_configs` key that you deem necessary. It's also worth sanity checking the generated scrape configs.

7. Apply the generated configuration to your Grafana agents!

## Generating a Configuration for Logs Using the Grafana Agent Operator?

The Grafana Agent Operator can be used to generate a configuration for log scraping, but there isn't much need to do so. Logs scrape jobs aren't cluster-dependant so most generic configs will work, such as the one in the [Grafana Agent Logs docs](https://grafana.com/docs/grafana-cloud/kubernetes/agent-k8s/k8s_agent_logs/). If you're wondering, the configuration generated by the operator doesn't differ much from the example one in the docs.
