{% from "storm/map.jinja" import storm, zmq, jzmq with context %}
{% from "storm/map.jinja" import libsodium as lsi with context %}

storm|create_zmq_directories:
  file.directory:
    - user: {{ storm.user_name }}
    - group: {{ storm.user_name }}
    - mode: 755
    - makedirs: true
    - names:
        - {{ zmq.prefix }}/{{ zmq.real_name }}
        - {{ jzmq.prefix }}/{{ jzmq.real_name }}
        - {{ lsi.prefix  }}/{{ lsi.real_name }}

storm|download_sodium:
  cmd.run:
    - name: curl -L '{{ lsi.source_url }}' | tar xz
    - cwd: {{ lsi.prefix }}
    - unless: test -f {{ lsi.real_home }}
    - require:
        - file: storm|build_dir

storm|download_zmq:
  cmd.run:
    - name: curl -L {{ zmq.source_url }} | tar xz
    - cwd: {{ zmq.prefix }}
    - unless: test -d {{ zmq.real_home }}
    - require:
        - file: storm|build_dir

storm|download_jzmq:
  cmd.run:
    - name: curl -L {{ jzmq.source_url }} | tar xz
    - cwd: {{ jzmq.prefix }}
    - unless: test -d {{ jzmq.real_home }}
    - require:
        - file: storm|build_dir
          
storm|install_sodium:
  cmd.run:
    - name: |
        cd {{ lsi.real_home }}
        ./configure --prefix={{ lsi.prefix }}
        make
        make install
    - cwd: {{ lsi.prefix }}
    - shell: /bin/bash
    - timeout: 300
    - unless: test -x {{ lsi.prefix }}/lib/libsodium.so
    - require:
        - cmd: storm|download_sodium
          
storm|install_zmq:
  cmd.run:
    - name: |
        cd {{ zmq.real_home }}
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
    - name: |
        cd {{ jzmq.real_home }}
        ./autogen.sh
        ./configure
        make
        make install
    - cwd: {{ jzmq.prefix }}
    - shell: /bin/bash
    - timeout: 300
    - unless: test -x {{ jzmq.real_home }}/autogen.sh
    - require:
        - file: storm|create_directories
