{% from "storm/map.jinja" import storm, meta with context %}
include:
  - sun-java
  - sun-java.env
  
{% set zmq = storm.zmq %}
{% set jzmq = storm.jzmq %}
{% set lsi = storm.libsodium %}
{% set zmq_name = zmq.name % zmq.version %}
{% set jzmq_name = jzmq.name % jzmq.version %}
{% set lsi_name = lsi.name % lsi.version %}

storm|create_zmq_directories:
  file.directory:
    - user: root
    - group: root
    - mode: 755
    - makedirs: true
    - require:
        - user: {{ storm.user }}
    - names:
        - {{ zmq.prefix }}/{{ zmq.name % zmq.version}}
        - {{ jzmq.prefix }}/{{ jzmq.name % jzmq.version }}
        - {{ lsi.prefix  }}/{{ lsi.name % lsi.version }}

storm|download_sodium:
  cmd.run:
    - name: |
        curl -L '{{ lsi.source_url % lsi  }}' | tar xz
        rm -f {{ lsi.prefix }}/lib/libsodium.*
    - cwd: {{ lsi.prefix }}
    - unless: test -f {{ lsi.prefix }}/{{ lsi_name }}/autogen.sh
    - require:
        - file: storm|build_dir
        - sls: sun-java.env
          
storm|download_zmq:
  cmd.run:
    - name: |
        curl -L {{ zmq.source_url  % zmq }} | tar xz
        rm -f {{ zmq.prefix }}/lib/libzmq*
    - cwd: {{ zmq.prefix }}
    - unless: test -f {{ zmq.prefix }}/{{ zmq_name }}/autogen.sh
    - require:
        - file: storm|build_dir
        - sls: sun-java.env

storm|download_jzmq:
  cmd.run:
    - name: |
        curl -L {{ jzmq.source_url % jzmq }} | tar xz
        rm -f {{ jzmq.prefix }}/lib/libjzmq*
    - cwd: {{ jzmq.prefix }}
    - unless: test -f {{ jzmq.prefix }}/{{ jzmq_name }}/autogen.sh
    - require:
        - file: storm|build_dir
        - sls: sun-java.env
          
storm|install_sodium:
  cmd.run:
    - name: |
        cd {{ lsi.prefix }}/{{ lsi_name }}
        [[ -f ./configure ]] && rm ./configure        
        ./autogen.sh
        ./configure
        make && make install
        ldconfig -n {{ lsi.prefix }}
    - cwd: {{ lsi.prefix }}
    - shell: /bin/bash
    - timeout: 300
    - unless: test -x {{ lsi.prefix }}/lib/libsodium.so
    - require:
        - cmd: storm|download_sodium

storm|install_zmq:
  cmd.run:
    - name: |
        cd {{ zmq.prefix }}/{{ zmq_name }}
        [[ -f ./configure ]] && rm ./configure
        ./autogen.sh
        ./configure
        make && make install
        ldconfig -n {{ zmq.prefix }}
    - cwd: {{ zmq.prefix }}
    - shell: /bin/bash
    - timeout: 300
    - unless: test -x {{ zmq.prefix }}/lib/libzmq.so
    - require:
        - cmd: storm|download_zmq
        - cmd: storm|install_sodium


storm|install_jzmq:
  cmd.run:
    - name: |
        cd {{ jzmq.prefix }}/{{ jzmq_name }}
        ./autogen.sh
        ./configure
        make
        make install
        ldconfig -n {{ jzmq.prefix }}
    - cwd: {{ jzmq.prefix }}
    - shell: /bin/bash
    - timeout: 300
    - unless: test -x {{ lsi.prefix }}/lib/libjzmq.so
    - require:
        - file: storm|create_directories
        - cmd: storm|download_zmq
        - cmd: storm|install_sodium
        - cmd: storm|install_zmq        


storm|remove-python-zmq:
  pkg.removed:
    - name: python-zmq

storm|install-python-zmq:
  pkg.installed:
    - name: python-zmq
    - require:
        - pkg: storm|remove-python-zmq
      
storm|refresh-salt:
  module.run:
    - name: saltutil.sync_all
    - refresh: True
    - require:
        - pkg: storm|install-python-zmq

