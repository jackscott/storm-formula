{% from "storm/map.jinja" import storm, config with context %}

include:
  - storm

{% macro state_builder(name, enabled, command) %}

storm|{{ name }}-default-file:
  file.managed:
    - name: /etc/default/{{ name }}
    - source: salt://storm/files/etc_default.conf
    - template: jinja
    - context:
        service: {{ name }}
        enabled: {{ enabled }}
    - user: root
    - group: root
    - mode: 644

storm|{{ name }}-upstart:
  file.managed:
    - name: /etc/init/{{ name }}.conf
    - source: salt://storm/files/upstart.init.conf
    - user: root
    - group: root
    - mode: 0644
    - template: jinja
    - context:
        service: {{ name }}
        command: {{ command }}
    - require:
        - file: storm|{{ name }}-default-file
  service.running:
    - name: {{ name }}
    - enable: {{ enabled }}
    - init_delay: 10
    - watch:
      - file: storm|{{ name }}-upstart
      - file: storm|{{ name }}-default-file
      - file: storm|storm-config
    - require:
        - file: storm|{{ name }}-upstart
{% endmacro %}

{% for cmd in ['supervisor', 'drpc', 'logviewer'] %}
{% with service = storm.services[cmd] %}
{{ state_builder(service['name'], service['enabled'], cmd) }}
{% endwith %}
{% endfor %}
