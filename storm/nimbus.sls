{% from "storm/map.jinja" import storm,meta with context %}

include:
  - storm

{%- with service = storm.services.nimbus %}        
storm|nimbus-enabled-file:
  file.managed:
    - name: /etc/default/{{ service['name'] }}
    - source: salt://storm/files/etc_default.conf
    - mode: 644
    - user: root
    - group: root
    - order: 10
    - context:
        enabled: {{ service['enabled'] }}
  
storm|nimbus-upstart:
  file.managed:
    - name: /etc/init/{{ service['name'] }}.conf
    - source: salt://storm/files/nimbus.init.conf
    - template: jinja
    - mode: 644
    - user: root
    - group: root
    - context:
        storm: {{ storm }}
        meta: {{ meta }}
        java_home: {{ meta.java_home }}
        local_cache: {{ salt['pillar.get']('storm:config:storm:local.dir', '/mnt/storm/storm-local') }}
        
  service.running:
    - name: {{ service['name'] }}
    - enable: {{ service['enabled'] }}
    - init_delay: 10
    - watch:
      - file: storm|nimbus-enabled-file
      - file: storm|nimbus-upstart

{% endwith %}
