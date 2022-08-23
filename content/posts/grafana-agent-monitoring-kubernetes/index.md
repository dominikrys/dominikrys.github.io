---
title: "Scraping Grafana Agent Metrics in Kubernetes"
date: 2022-07-03T10:08:23+01:00
ShowToc: true
searchHidden: false
cover:
  image: "img/cover.jpg"
  alt: "Cover"
tags:
  - Kubernetes
  - Grafana
  - Observability
  - Site Reliability Engineering
---

After deploying the [Grafana Agent](https://github.com/grafana/agent) in a Kubernetes cluster, you'll most likely want to monitor it to ensure that no observability data gets lost. Grafana provides a [comprehensive guide](https://grafana.com/docs/grafana-cloud/agent/agent_monitoring/) on how to configure alerts for the agent, but I found it to not work for all cases. Namely, enabling agent integration didn't enable scraping metrics of the agent itself. This could be due to running the Grafana Agent in Kubernetes, which the guide may not be targeted at, or due to configuring the agent in a manner that deviates from Grafana's recommended way.

## Available Grafana Agent Metrics

To check what metrics are available from the Grafana Agent, you first need to have the metrics exposed from the agent pods as a Service. This is also a prerequisite to the rest of this post. I will use the Service configuration from the [Grafana Agent v0.25.1 example deployment](https://github.com/grafana/agent/blob/v0.25.1/production/kubernetes/agent-bare.yaml) as an example.

Once you have the Service running in your cluster, get the name of one of your Grafana agent pods:

```bash
kubectl get pods --namespace <GRAFANA AGENT NAMESPACE>
```

Take one of the pod names and port forward its port 80 to some available port on your local machine, e.g. 12345:

```bash
kubectl port-forward <GRAFANA AGENT POD NAME> --namespace <GRAFANA AGENT NAMESPACE> 80:12345
```

In another terminal instance, get the list of exposed metrics:

```bash
curl localhost:12345/metrics
```

Alongside the listed metrics, the agent will also report an `up` metric for the Grafana Agent service.

## Scraping Grafana Agent Metrics

To scrape the metrics of the Grafana Agent, a [ServiceMonitor](https://github.com/prometheus-operator/prometheus-operator/blob/main/Documentation/user-guides/getting-started.md) or a [scrape config](https://prometheus.io/docs/prometheus/latest/configuration/configuration/#scrape_config) for the agent metrics is required. The ServiceMonitor will work if you're using the [Grafana Agent operator](https://grafana.com/docs/agent/latest/operator/) for your Grafana Agent deployment, and the scrape config is required if you're running the agent without using the operator.

### ServiceMonitor

Modify the namespace in the ServiceMonitor definition below to the namespace that your Grafana agent runs in. Then, deploy the ServiceMonitor onto your cluster with `kubectl apply`:

```yaml
---
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  labels:
    name: grafana-agent
  name: grafana-agent
  namespace: NAMESPACE
spec:
  endpoints:
    - bearerTokenFile: /var/run/secrets/kubernetes.io/serviceaccount/token
      port: http-metrics
      path: /metrics
      tlsConfig:
        insecureSkipVerify: true
  selector:
    matchLabels:
      name: grafana-agent
```

### Scrape config

Modify the namespace in the scrape config definition below to the namespace that your Grafana agent runs in. Then, append the scrape config to the end of your `scrape_configs` block in the Grafana Agent `ConfigMap`. Finally, apply the scrape config using `kubectl apply` and restart your Grafana Agent using `kubectl rollout restart sts/grafana-agent --namespace NAMESPACE`:

```yaml
- bearer_token_file: /var/run/secrets/kubernetes.io/serviceaccount/token
  honor_labels: false
  job_name: serviceMonitor/grafana-agent/grafana-agent/0
  kubernetes_sd_configs:
    - namespaces:
        names:
            - NAMESPACE
      role: endpoints
  metrics_path: /metrics
  relabel_configs:
    - source_labels:
        - job
      target_label: __tmp_prometheus_job_name
    - action: keep
      regex: grafana-agent
      source_labels:
        - __meta_kubernetes_service_label_app
    - action: keep
      regex: http-metrics
      source_labels:
        - __meta_kubernetes_endpoint_port_name
    - regex: Node;(.*)
      replacement: $1
      separator: ;
      source_labels:
        - __meta_kubernetes_endpoint_address_target_kind
        - __meta_kubernetes_endpoint_address_target_name
      target_label: node
    - regex: Pod;(.*)
      replacement: $1
      separator: ;
      source_labels:
        - __meta_kubernetes_endpoint_address_target_kind
        - __meta_kubernetes_endpoint_address_target_name
      target_label: pod
    - source_labels:
        - __meta_kubernetes_namespace
      target_label: namespace
    - source_labels:
        - __meta_kubernetes_service_name
      target_label: service
    - source_labels:
        - __meta_kubernetes_pod_name
      target_label: pod
    - source_labels:
        - __meta_kubernetes_pod_container_name
      target_label: container
    - replacement: $1
      source_labels:
        - __meta_kubernetes_service_name
      target_label: job
    - replacement: http-metrics
      target_label: endpoint
  tls_config:
    insecure_skip_verify: true
```

## Final Word on Cardinality

Your metrics should now be available in Grafana Cloud. Note that some metrics (e.g. `prometheus_target_sync_length_seconds` and `promtail_log_entries_bytes_bucket`) have a high cardinality, so you may want to filter some metrics labels to reduce your metrics usage. The post on [reducing Prometheus metrics usage](https://grafana.com/docs/grafana-cloud/metrics-control-usage/control-prometheus-metrics-usage/usage-reduction/) from Grafana can come in handy for this.
