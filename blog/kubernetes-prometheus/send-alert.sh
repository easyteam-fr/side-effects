alerts1='[
  {
    "labels": {
       "alertname": "CPUConsumption",
       "instance": "ec2-user"
     },
     "annotations": {
        "info": "The CPU usage is above 80 percent",
        "summary": "please check the service usage"
      }
  }
]'
curl -XPOST -d"$alerts1" http://localhost:9093/api/v1/alerts
