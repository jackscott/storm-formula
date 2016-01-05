{% from "storm/map.jinja" import storm, zmq with context %}

include:
  - storm.zmq
  
storm|install_deps:
  pkg:
    - installed
    - pkgs:
        - unzip
        - libtool
        - autoconf
        - pkg-config
        - libtool
        - automake
        - autoconf
        - pkg-config
        - maven
        
storm|build_dir:
  file.directory:
    - user: root
    - group: root
    - mode: 755
    - makedirs: true
    - names:
        - {{ storm.build_dir }}

storm|create_user-{{ storm.user_name }}:
  group.present:
    - name: {{ storm.user_name }}
  user.present:
    - name: {{ storm.user_name }}
    - fullname: "Apache Storm User"
    - createhome: false
    - shell: /usr/sbin/nologin
    - gid_from_name: true
    - groups:
        - {{ storm.user_name }}
    - unless: getent passwd {{ storm.user_name }}
  
storm|create_directories:
  file.directory:
    - user: {{ storm.user_name }}
    - group: {{ storm.user_name }}
    - mode: 755
    - makedirs: true
    - names:
        - {{ storm.real_home }}
        - {{ storm.log_dir }}


storm|install_from_source:
  cmd.run:
    - cwd: {{ storm.real_home }}
    - name: curl -L '{{ storm.source_url }}' | tar xz
    - shell: /bin/bash
    - timeout: 300
    - unless: test -x {{ storm.real_name }}/bin/storm
    - require:
        - file: storm|create_directories

  alternatives.install:
    - name: storm-home-link
    - link: {{ storm.alt_home }}
    - path: {{ storm.real_home }}
    - priority: 30
    - require:
        - cmd: storm|install_from_source

storm|update_path:
  file.managed:
    - name: /etc/profile.d/storm.sh
    - source: salt://storm/files/profile.sh
    - template: jinja
    - mode: 644
    - user: root
    - group: root
    - context:
      storm_bin: {{ storm.real_home }}/bin

# storm|storm_config:
#   file.managed:
#     - name: {{ storm.real_home }}/conf/storm.yaml
#     - source: salt://storm/files/storm.yaml
#     - template: jinja
#     - mode: 644
#     - user: root
#     - group: root
#     - context:
#       storm: {{ storm }}
#       jvm_options: {{ storm.jvm_options }}
#       config: {{ storm.config }}
