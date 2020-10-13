* ![Master](https://github.com/wep4you/logstash/workflows/buildx/badge.svg?branch=master)
* ![v7.9.2](https://github.com/wep4you/logstash/workflows/buildx/badge.svg?branch=v7.9.1)
* ![v7.9.1](https://github.com/wep4you/logstash/workflows/buildx/badge.svg?branch=v7.9.1)

# Elastic Logstash-OSS
Multiarch Docker File for Elastics Logstash Based on the official Docker Repo https://github.com/elastic/logstash
Base Image is Buster:Slim, automatic build with Docker-Hub Pipeline for linux/amd64, linux/arm/v7, linux/arm64/v8,linux/386

The arm64/v8 is in use on on RaspberryPi-4 Kubernetes Cluster with k3s

## Docker Config Examples at Elastic
https://www.elastic.co/guide/en/logstash/current/docker-config.html

### Pipeline Configuration
It is essential to place your pipeline configuration where it can be found by Logstash. By default, the container will look in /usr/share/logstash/pipeline/ for pipeline configuration files.

In this example we use a bind-mounted volume to provide the configuration via the docker run command:

    docker run --rm -it -v ~/pipeline/:/usr/share/logstash/pipeline/ wep4you/logstash:latest

Every file in the host directory ~/pipeline/ will then be parsed by Logstash as pipeline configuration.

If you don’t provide configuration to Logstash, it will run with a minimal config that listens for messages from the Beats input plugin and echoes any that are received to stdout. In this case, the startup logs will be similar to the following:

    Sending Logstash logs to /usr/share/logstash/logs which is now configured via log4j2.properties.
    [2016-10-26T05:11:34,992][INFO ][logstash.inputs.beats    ] Beats inputs: Starting input listener {:address=>"0.0.0.0:5044"}
    [2016-10-26T05:11:35,068][INFO ][logstash.pipeline        ] Starting pipeline {"id"=>"main", "pipeline.workers"=>4, "pipeline.batch.size"=>125, "pipeline.batch.delay"=>5, "pipeline.max_inflight"=>500}
    [2016-10-26T05:11:35,078][INFO ][org.logstash.beats.Server] Starting server on port: 5044
    [2016-10-26T05:11:35,078][INFO ][logstash.pipeline        ] Pipeline main started
    [2016-10-26T05:11:35,105][INFO ][logstash.agent           ] Successfully started Logstash API endpoint {:port=>9600}

This is the default configuration for the image, defined in /usr/share/logstash/pipeline/logstash.conf. If this is the behaviour that you are observing, ensure that your pipeline configuration is being picked up correctly, and that you are replacing either logstash.conf or the entire pipeline directory.

### Bind-mounted settings files
The image provides several methods for configuring settings. The conventional approach is to provide a custom logstash.yml file.
Settings files can also be provided through bind-mounts. Logstash expects to find them at /usr/share/logstash/config/.

It’s possible to provide an entire directory containing all needed files:

    docker run --rm -it -v ~/settings/:/usr/share/logstash/config/ wep4you/logstash:latest

Alternatively, a single file can be mounted:

    docker run --rm -it -v ~/settings/logstash.yml:/usr/share/logstash/config/logstash.yml wep4you/logstash:latest

Bind-mounted configuration files will retain the same permissions and ownership within the container that they have on the host system. Be sure to set permissions such that the files will be readable and, ideally, not writeable by the container’s logstash user (UID 1000).

## Links

Actual and Pre-Built Beats for File-Beat and Metric-Beat also for ARM and ARM64: 
* https://github.com/mnorrsken/beats