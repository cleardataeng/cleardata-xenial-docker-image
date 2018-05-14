Info for external apt repos can be dropped into this dir.  The
Dockerfile will then automatically go through and set them up.  The
action taken depends on the filename's extension:

*.key: each will be fed to apt-key

*.list: each will be added to /etc/apt/sources.list.d
