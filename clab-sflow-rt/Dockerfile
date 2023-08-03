FROM sflow/sflow-rt:latest
LABEL url=https://hub.docker.com/r/sflow/clab-sflow-rt
RUN /sflow-rt/get-app.sh sflow-rt prometheus && /sflow-rt/get-app.sh sflow-rt browse-metrics && /sflow-rt/get-app.sh sflow-rt browse-flows && /sflow-rt/get-app.sh sflow-rt containerlab-dashboard
