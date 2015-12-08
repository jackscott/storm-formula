{% from 'storm/settings.sls' import storm,zmq with context %}
# 
# git@github.com:zeromq/jzmq.git
# https://github.com/apache/storm/archive/v0.10.0.tar.gz

storm|install_deps:
  pkg:
    - installed
    - pkgs:
        - zeromq
        - zeromq-devel
        - unzip
        - libtool
        - autoconf
        - pkg-config
        - libtool
        - automake
        - autoconf
        - build-essential
        - pkg-config

storm|create_directories:
  file.directory:
    - user: {{ storm.user_name }}
    - group: {{ storm.user_name }}
    - mode: 755
    - makedirs: true
    - names:
        - {{ storm.real_home }}
        - {{ storm.log_dir }}
        - {{ zmq.real_home }}
        - {{ zmq.log_dir }}
        - {{ zmq.jzmq_real_home }}
        
storm|install_zmq:
  cmd.run:
    - cwd: {{ zmq.real_home }}
    - names:
        - curl -L '{{ zmq.source_url }}' | tar xz
        - ./autogen.sh
        - ./configure 
        - make
        - make install 
    - shell: /bin/bash
    - timeout: 300
    - unless: test -x {{ zmq.real_home }}/version.sh
    - require:
        - file: storm|create_directories
          
  alternatives.install:
    - name: zmq-path-link
    - link: {{ zmq.prefix }}
    - path: {{ zmq.real_home }}
    - priority: 30
    - require:
        - cmd: storm|install_zmq

storm|install_jzmq:
  cmd.run:
    - cwd: {{ zmq.jzmq_real_home }}
    - names:
        - curl -L '{{ zmq.jzmq_source_url}}' | tar xz
        - ./autogen.sh
        - ./configure
        - make
        - make install
    - shell: /bin/bash
    - timeout: 300
    - unless: test -x {{ zmq.jzmq_real_home }}/autogen.sh
    - require:
        - file: storm|create_directories

storm|install_from_source:
  cmd.run:
    - cwd: {{ storm.real_home }}
    - name: curl -L '{{ storm.source_url }}' | tar xz
    - shell: /bin/bash
    - timeout: 300
    - unless: test -x {{ storm.real_home }}/bin/storm
    - require:
        - file: storm|create_directories
            
  alternatives.install:
    - name: storm-home-link
    - link: {{ storm.prefix }}
    - path: {{ storm.real_home }}
    - priority: 30
    - require:
        - cmd: storm|install_from_source

