# EPICS softioc docker container

Create a Dockerfile in your preferred folder
```
FROM iarredondo/epics-server
```
Then run:
```
$ docker build -t epics-server .

$ docker run --name epics_server --rm -p 5064:5064 -p 5064:5064/udp -p 5065:5065 -p 5065:5065/udp -dit epics-server
```
OR

Attaching a local volume:
```
$ docker run --name epics_server --rm -p 5064:5064 -p 5064:5064/udp -p 5065:5065 -p 5065:5065/udp -dit -v <path-to-your-db>/db:/usr/local/epics/softioc/db epics-server
```
You can avoid the detached mode just changing the -dit to -it to ensure that your local db has been properly parsed.

After that you can use iarredondo/epics container to check if it is working properly.

Just run the epics container and update the EPICS_CA_ADDR_LIST, then caget or camonitor what you want.
