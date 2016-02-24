{% from "storm/map.jinja" import storm, meta with context %}
{%- set java_home = salt['environ.get']('JAVA_HOME', '/usr/lib/java') %}
{%- set local_dir =  salt['pillar.get']('storm:config:storm:local.dir', '/tmp/storm-local') %} 

include:
  - storm


{%- with service = storm.services.supervisor %}
storm|supervisor-default-file:
  file.managed:
    - name: /etc/default/{{ service['name'] }}
    - source: salt://storm/files/etc_default.conf
    - template: jinja
    - context:
        service: {{ service['name'] }}
        enabled: {{ service['enabled'] }}
    - user: root
    - group: root
    - mode: 644

storm|supervisor-upstart:
  file.managed:
    - name: /etc/init/{{ service['name'] }}.conf
    - source: salt://storm/files/upstart.init.conf
    - user: root
    - group: root
    - mode: 0644
    - template: jinja
    - context:
        service: {{ service['name'] }}
        command: supervisor
    - require:
        - file: storm|supervisor-default-file
  service.running:
    - name: {{ service['name'] }}
    - enable: {{ service['enabled'] }}
    - init_delay: 10
    - watch:
      - file: storm|supervisor-upstart
      - file: storm|supervisor-default-file
      - file: storm|storm-config
        
    - require:
        - file: storm|supervisor-upstart
{% endwith %}

{% with service = storm.services.logviewer %}
storm|logviewer-default-file:
  file.managed:
    - name: /etc/default/{{ service['name'] }}
    - source: salt://storm/files/etc_default.conf
    - template: jinja
    - context:
        enabled: {{ service['enabled'] }}
        service: {{ service['name'] }}
    - user: root
    - group: root
    - mode: 644
          

storm|logviewer-upstart:
  file.managed:
    - name: /etc/init/{{ service['name'] }}.conf
    - source: salt://storm/files/logviewer.init.conf
    - user: root
    - group: root
    - mode: 0644
    - template: jinja
    - context:
        service: {{ service['name'] }}
        user: {{ storm.user }}
        real_home: {{ meta['home'] }}
        java_home: {{ java_home }}
        local_cache: {{ local_dir }}
    - require:
        - file: storm|supervisor-default-file
        - file: storm|supervisor-upstart
  service.running:
    - name: {{ service['name'] }}
    - enable: {{ service['enabled']}}
    - init_delay: 10
    - watch:
        - file: storm|logviewer-upstart
        - file: storm|supervisor-default-file
        - file: storm|storm-config

{% endwith %}

{% with service = storm.services.drpc %}
storm|drpc-default-file:
  file.managed:
    - name: /etc/default/{{ service['name'] }}
    - source: salt://storm/files/etc_default.conf
    - template: jinja
    - context:
        enabled: {{ service['enabled'] }}
        service: {{ service['name'] }}
    - user: root
    - group: root
    - mode: 644


storm|drpc-upstart:
  file.managed:
    - name: /etc/init/{{ service['name'] }}.conf
    - source: salt://storm/files/upstart.init.conf
    - user: root
    - group: root
    - mode: 0644
    - template: jinja
    - context:
        service: {{ service['name'] }}
        command: drpc
    - require:
        - file: storm|drpc-default-file
  service.running:
    - name: {{ service['name'] }}
    - enable: {{ service['enabled'] }}
    - init_delay: 10
    - watch:
        - file: storm|drpc-upstart
        - file: storm|drpc-default-file
        - file: storm|storm-config
{% endwith %}
