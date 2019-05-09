from golang:1.12 as builder
env GO111MODULE=on
workdir github.com/ottoyiu/cfs-cpu-burn
copy . .
run make target/cmd/cfs-cpu-burn && cp target/cmd/cfs-cpu-burn /app

from quay.io/prometheus/busybox:latest
copy --from=builder /app /app
entrypoint ["/app"]
