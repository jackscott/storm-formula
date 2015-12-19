{% from 'storm/settings.sls' import storm,zmq with context %}

storm|create_zmq_directories:
  file.directory:
    - user: {{ storm.user_name }}
    - group: {{ storm.user_name }}
    - mode: 755
    - makedirs: true
    - names:
        - {{ zmq.real_home }}
        - {{ zmq.log_dir }}
        - {{ zmq.jzmq_real_home }}
        - {{ zmq.sodium_real_home }}

storm|download_sodium:
  cmd.run:
    - name: wget -c {{ zmq.sodium_source_url }}
    - cwd: {{ zmq.build_dir }}
    - unless: test -f {{ zmq.build_dir }}/{{ zmq.sodium_version_name }}.tar.gz
    - require:
        - file: storm|build_dir

storm|download_zmq:
  cmd.run:
    - name: wget -c {{ zmq.source_url }}
    - cwd: {{ zmq.build_dir }}
    - unless: test -f {{ zmq.build_dir }}/{{ zmq.version_name }}.tar.gz
    - require:
        - file: storm|build_dir

storm|download_jzmq:
  cmd.run:
    - name: wget -c {{ zmq.jzmq_source_url }}
    - cwd: {{ zmq.build_dir }}
    - unless: test -f {{ zmq.build_dir }}/v{{ zmq.jzmq_version }}.tar.gz
    - require:
        - file: storm|build_dir
          
storm|install_sodium:
  cmd.run: 
    - name: |
        tar xvf {{ zmq.prefix }}/source/{{ zmq.sodium_version_name }}.tar.gz
        cd {{ zmq.sodium_version_name }}
        ./configure
        make
        make check
        make install
    - cwd: {{ zmq.prefix }}
    - shell: /bin/bash
    - timeout: 300
    - unless: test -x /usr/local/lib/libsodium.so.18.0.0
    - require:
        - cmd: storm|download_sodium
          
storm|install_zmq:
  cmd.run:
    - name: |
        tar xvf {{ zmq.build_dir }}/{{ zmq.version_name }}.tar.gz
        cd {{ zmq.version_name }}
        ./autogen.sh
        ./configure
        make
        make install 
    - cwd: {{ zmq.prefix }}
    - shell: /bin/bash
    - timeout: 300
    - unless: test -x {{ zmq.prefix }}/lib/libjzmq.so
    - require:
        - cmd: storm|download_zmq
          
storm|install_jzmq:
  cmd.run:
    - cwd: {{ zmq.prefix }}
    - names:
        - tar xvf {{ zmq.build_dir }}/v{{ zmq.jzmq_version}}.tar.gz
        - cd {{ zmq.jzmq_real_home }}
        - ./autogen.sh
        - ./configure
        - make
        - make install
    - shell: /bin/bash
    - timeout: 300
    - unless: test -x {{ zmq.jzmq_real_home }}/autogen.sh
    - require:
        - file: storm|create_directories
