# Transmission Dockerfile

## start transmission
run on default port
```bash
docker run  -p 9091:9091 philiplehmann/transmission:latest
```

define port
```bash
docker run -p 5000:5000 --env PORT=5000 philiplehmann/transmission:latest
```

change log level
```bash
docker run -p 9091:9091 --env LOG_LEVEL=debug philiplehmann/transmission:latest
```
