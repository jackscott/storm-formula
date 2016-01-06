{% from "storm/map.jinja" import storm,meta with context %}

include:
  - storm
  - storm.zmq

# storm|nimbus-conf:
#   file.managed:
#     - name: {{ meta['conf_dir'] }}/storm.yaml
#     - source: salt://storm/files/storm.yaml
#     - user: {{ storm.user }}
#     - group: {{ storm.user }}
#     - mode: 644
#     - require:
#         - sls: storm

storm|ui-upstart:
  file.managed:
    - name: /etc/init/storm-ui.conf
    - source: salt://storm/files/ui.init.conf
    - template: jinja
    - mode: 644
    - user: root
    - group: root
    - context:
        storm: {{ storm }}
        meta: {{ meta }}
    # - require:
    #     - file: storm|nimbus-conf


storm|ui-enabled-file:
  file.managed:
    - name: /etc/default/storm_ui
    - mode: 644
    - user: root
    - group: root
    - contents: |
        ENABLE="yes"

storm|ui-service:
  service.running:
    - name: storm-ui
    - enable: true
    - init_delay: 10
    - watch:
      - file: storm|ui-enabled-file
      - file: storm|ui-upstart
