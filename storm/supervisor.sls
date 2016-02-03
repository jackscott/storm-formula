{% from "storm/map.jinja" import storm, meta with context %}


include:
  - storm

storm|supervisor-default-file:
  file.managed:
    - name: /etc/default/storm-supervisor
    - contents: |
        ENABLE="yes"
    - user: root
    - group: root
    - mode: 644

storm|supervisor-upstart:
  file.managed:
    - name: /etc/init/supervisor.conf
    - source: salt://storm/files/supervisor.init.conf
    - user: root
    - group: root
    - mode: 0644
    - template: jinja
    - context:
        user: {{ storm.user }}
        real_home: {{ meta['home'] }}
        java_home: {{ salt['environ.get']('JAVA_HOME', '/usr/lib/java') }}
        local_cache: {{ salt['pillar.get']('storm:config:storm.local.dir', '/mnt/storm/storm-local') }}        
    - require:
        - file: storm|supervisor-default-file


storm|supervisor-service:
  service.running:
    - name: storm-supervisor
    - enable: true
    - init_delay: 10
    - watch:
      - file: storm|supervisor-upstart
      - file: storm|supervisor-default-file
    - require:
        - file: storm|supervisor-upstart
