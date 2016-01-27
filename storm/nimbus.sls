{% from "storm/map.jinja" import storm,meta with context %}

include:
  - storm

storm|nimbus-upstart:
  file.managed:
    - name: /etc/init/storm-nimbus.conf
    - source: salt://storm/files/nimbus.init.conf
    - template: jinja
    - mode: 644
    - user: root
    - group: root
    - context:
        storm: {{ storm }}
        meta: {{ meta }}

storm|nimbus-enabled-file:
  file.managed:
    - name: /etc/default/storm-nimbus
    - mode: 644
    - user: root
    - group: root
    - contents: |
        ENABLE="yes"

storm|service:
  service.running:
    - name: storm-nimbus
    - enable: true
    - init_delay: 10
    - watch:
      - file: storm|nimbus-enabled-file
      - file: storm|nimbus-upstart
