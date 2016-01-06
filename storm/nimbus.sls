{% from "storm/map.jinja" import storm,meta with context %}

include:
  - storm

storm|nimbus-conf:
  file.managed:
    - name: {{ meta['conf_dir'] }}/storm.yaml
    - source: salt://storm/files/storm.yaml
    - user: {{ storm.user }}
    - group: {{ storm.user }}
    - mode: 644
    - require:
        - sls: storm

storm|nimbus-upstart:
  file.managed:
    - name: /etc/init/nimbus.conf
    - source: salt://storm/files/nimbus.init.conf
    - template: jinja
    - mode: 644
    - user: root
    - group: root
    - context:
        storm: {{ storm }}
        meta: {{ meta }}
    - require:
        - file: storm|nimbus-conf


storm|nimbus-enabled-file:
  file.managed:
    - name: /etc/default/nimbus
    - mode: 644
    - user: root
    - group: root
    - contents: |
        ENABLE="yes"

storm|service:
  service.running:
    - name: nimbus
    - enable: true
    - init_delay: 10
    - watch:
      - file: storm|nimbus-enabled-file
      - file: storm|nimbus-upstart
      - file: storm|nimbus-conf
