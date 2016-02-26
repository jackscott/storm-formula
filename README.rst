=========
Apache Storm
=========

Formula to set up and configure the components of an Apache Storm cluster using Salt.

.. note::

    See the full `Salt Formulas installation and usage instructions
    <http://docs.saltstack.com/en/latest/topics/development/conventions/formulas.html>`_.

Minion Configuration
====================

**Storm** uses **Java** but this formula doesn't pin you down to any one installation method, but **$JAVA_HOME** does need to be set.    This formula looks for `java_home` to be set in the top level of the `grains` first, then the `pillar` and finally defaults to `/usr/lib/java`.  This value is used in the upstart scripts for each of the services installed.

*Pro Tip*: Storm requires Java 7 but you can (and should) use Java 8.  I use the `sun-java <https://github.com/saltstack-formulas/sun-java-formula>`_ formula, it's pretty sweet you should check it out.

---

**Storm** is a big fan of **ZK** and needs to know all about it in `storm.yaml`. This formula makes a big assumption that you're using `roles` to describe your minions and does this

.. code-block:: python

   zk_hosts = salt['mine.get']('roles:zookeeper', 'network.ip_addrs', expr_form='grain').keys()


In my world, I set the `minion.id` to the FQDN (or at least resolvable) of the node itself so running `network.ip_addrs eth0` gets me back a map where the keys are `node.domain.com` and values are lists of IPs.  This is a huge assumption and I don't really like it but it's what landed, if you've got an idea open a ticket and get something going.


Storm Configuration
=====================
Because storm uses YAML for its configuration, this formula took the approach of using the `storm.config` namespace as a hash of "sections" which can be a mappable, iterable or scalar/bool/numeric which are then translated into the appropriate section of the config.  The `storm` state essentially does a for loop on `salt['pillar.get']('storm:config').items()` and then uses the `key` as a prefix to the nodes.


A more concrete example.

.. code-block:: yaml

   storm:
     config:
       nimbus:
         host: 'nimbus.example.com'
       ui:
         host: 'nimbus.example.com'
         port: '8888'
       storm:
         local.dir: '/mnt/storm/local-caches'
         log.dir: '/mnt/storm/logs'

The above pillar would yield a `storm.yaml` that looks like this:

.. code-block:: yaml
                
   ...
   nimbus.host: 'nimbus.example.com'
   ui.host: 'nimbus.example.com'
   ui.port: 8888
   storm.local.dir: '/mnt/storm/local-caches'
   storm.log.dir: '/mnt/storm/logs'
   ...

While you can rely on the defaults, they're pretty sane, you can actually set any field in `storm.yaml` as long as you stick with the naming convention outlined in the `pillar.example` and `defaults.yaml`



Available states
================

.. contents::
    :local:

``storm``
-------------

This is the basic state to install all of the dependencies and requirements to execute storm commands on a server and sets up the bash environment.


``storm.nimbus``
--------------------

Requires `storm` also creates an Upstart job called `storm-nimbus`.  It uses the same `storm.yaml` as everyone else and you can fine tune things using grains if necessary. This state must be installed, and im pretty sure it has to be installed before the supervisor states can run, you may need to highstate on the supervisor nodes more than once.

``storm.ui``
------------
Requires `storm` and creates and installs the `storm-ui` service for running the **UI**, Like `storm.nimbus` you only need one of these, and thats only the case if you need or want to use the Storm UI.

``storm.supervisor``
--------------------
Requires `storm`, creates and installs the following services

storm-supervisor
  Controls the worker threads and communicates with `nimbus`

storm-drpc
  I run a DRPC instance on my worker nodes so everyone can just talk local.

storm-logviewer
  Very handy for viewing the worker logs in the `storm.ui`

The last two services are hard-coded to be installed if the `storm.supervisor` formula is installed, this is not great but again, its what landed.


Lessions Learned
=================


How you structure you pillar/grains matter

.. code-block:: yaml
                
  storm:
    config:
      nimbus:
        host: 'nimbus.example.com'

is totally different from

.. code-block:: yaml

  storm:
    config:
      nimbus.host: 'nimbus.example.com'


The first example will correctly render `nimbus` as a hash with a single key `host` which has a string value. The second will yield a key of `nimbus.host` with a string value.  This is an important distinction and one to watch out for (here and in other formulas)  This formula tries to do the right thing when it sees a k/v in the top level of a config or with nested hashes, but its not perfect. Let the tickets commence!
