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
    - template: jinja
    - context:
        enabled: {{ service['enabled'] }}
        service: {{ service['name'] }}
        
storm|nimbus-upstart:
  file.managed:
    - name: /etc/init/{{ service['name'] }}.conf
    - source: salt://storm/files/upstart.init.conf
    - template: jinja
    - mode: 644
    - user: root
    - group: root
    - context:
        service: {{ service['name'] }}
        command: nimbus
        
  service.running:
    - name: {{ service['name'] }}
    - enable: {{ service['enabled'] }}
    - init_delay: 10
    - watch:
      - file: storm|nimbus-enabled-file
      - file: storm|nimbus-upstart

{% endwith %}
