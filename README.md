# Sandbox Manager

1. [API](#api)
1. [Configuration](#configuration)

## API  
`/api/{version}/{endpoint}`

### v1

#### `POST run`

*Params*

* `email` (required)

*Action*

* generate docker-compose file based on `./templates/docker-compose.yml` and run it up
* generate nginx config file based on `./templates/nginx.conf` into `./nginx_conf` dir
* restart `nginx` docker service

*Return*

```json
{
  "success": true,
  "data": {
    "email": "string",
    "instance_uuid": "string",
    "created_at": "date",
    "lifetime": "integer",
    "active": "boolean"
  }
}
```

or

```json
{
  "success": false,
  "errors": "array of strings"
}
```

#### `GET stop-overdue`

*Action*  
for each overdue sandbox:

* stop `docker-compose.yml`
* remove nginx config from ./nginx_conf
* restart `nginx` docker service

*Return*

```json
{
  "success": true,
  "stopped": "array of sandbox data",
  "failed": "array of sandbox data"
}
```

## Configuration

| env variable | |
|---|---|
| SANDBOX_PATH | path to dir where sandboxes data are stored |
| INSTANCES_LIMIT | upper limit of available active sandboxes |
