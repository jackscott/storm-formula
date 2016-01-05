{% from "storm/map.jinja" import storm with context %}

include:
  - storm

storm|nimbus_conf:
  file.managed:
    - name: {{ storm.conf_dir }}/storm.yaml
    - source: salt://storm/files/storm.yaml
    - user: {{ storm.user_name }}
    - group: {{ storm.user_name }}
    - mode: 644
    - require:
        - sls: storm

storm|nimbus_upstart:
  file.managed:
    - name: /etc/init/nimbus.conf
    - source: salt://storm/files/nimbus.init.conf
    - template: jinja
    - mode: 644
    - user: root
    - group: root
    - context:
        storm: {{ storm }}
    - require:
        - file: storm|nimbus_conf
