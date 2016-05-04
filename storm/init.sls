{%- from "storm/map.jinja" import  storm, meta, config with context %}
{%- set zk_hosts = salt['mine.get']('roles:zookeeper', 'network.ip_addrs', expr_form='grain').keys() %}

storm|install_deps:
  pkg:
    - installed
    - pkgs:
        - unzip
        - libtool
        - automake
        - autoconf
        - pkg-config
        - maven
        - gcc-multilib
        - libzmq3
        - curl
        - wget
storm|build_dir:
  file.directory:
    - user: root
    - group: root
    - mode: 755
    - makedirs: true
    - names:
        - {{ storm.build_dir }}
        - {{ storm.config_dir }}

        
storm|create_user-{{ storm.user }}:
  group.present:
    - name: {{ storm.user }}
  user.present:
    - name: {{ storm.user }}
    - fullname: "Apache Storm User"
    - createhome: false
    - shell: /bin/bash
    - gid_from_name: true
    - groups:
        - {{ storm.user }}
    - unless: getent passwd {{ storm.user }}

storm|create_directories:
  file.directory:
    - user: {{ storm.user }}
    - group: {{ storm.user }}
    - mode: 755
    - makedirs: true
    - names:
        - {{ meta['home'] }}
        - {{ config.storm['log.dir'] }}
        - {{ config.storm['local.dir'] }}
    - require:
        - user: storm|create_user-{{ storm.user }}

storm|logging-symlinks:
  file.symlink:
    - name: {{ '%s/logs'|format(meta['home']) }}
    - target: {{ config.storm['log.dir'] }}
    - user: {{ storm.user }}
    - group: {{ storm.user }}
    - mode: 775
    - force: true
    - require:
        - file: storm|create_directories
# 
storm|install_from_source:
  cmd.run:
    - cwd: {{ storm.prefix }}
    - name: |
        cd {{ storm.prefix }}
        curl -L '{{ storm.mirror_url % meta }}' |
        grep -A1 'site for your download:</p>' |
        tail -n1 |
        sed -e 's/<a .*href=['"'"'"]//' -e 's/["'"'"'].*$//' -e 's/<p>//' > /tmp/closest_mirror.txt
        curl -L `cat /tmp/closest_mirror.txt` | tar xz
    - shell: /bin/bash
    - timeout: 300
    - unless: test -x {{ meta['bin_dir'] }}/storm
    - require:
        - file: storm|create_directories

  alternatives.install:
    - name: storm-home-link
    - link: {{ meta['alt_home'] }}
    - path: {{ meta['home'] }}
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
        local_cache: {{ config.storm['local.dir'] }}

storm|storm-config:
  file.managed:
    - name: {{ meta['conf_dir'] }}/storm.yaml
    - source: salt://storm/files/storm.conf
    - template: jinja
    - mode: 644
    - user: {{ storm.user }}
    - group: {{ storm.user }}
    - context:
        zk_hosts: {{ zk_hosts }}
