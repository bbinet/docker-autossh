docker-autossh
==============

Autossh docker container.


Build
-----

To create the image `bbinet/autossh`, execute the following command in the
`docker-autossh` folder:

    docker build -t bbinet/autossh .

You can now push the new image to the public registry:
    
    docker push bbinet/autossh

Run
---

Then, when starting your autossh container, you will want to bind ports `22`
from the autossh container to a host external port.

You also need to provide a read-only `authorized_keys` file that will be use to
allow some users to connect with their public ssh key.

For example:

    $ docker pull bbinet/autossh

    $ docker run --name autossh \
        -v authorized_keys:/etc/ssh/authorized_keys:ro \
        -p 22:22 \
        bbinet/autossh
