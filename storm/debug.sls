{%- from 'storm/map.jinja' import storm, config with context %}

/tmp/storm.debug:
  file.managed:
    - contents: |
        # Storm object
        {%- for k,v in storm.items() %}
        {{ k }} => {{ v }}
        {%- endfor %}

        # Config object
        {%- for k,v in config.items() %}
        {{ k }} => {{ v }}
        {%- endfor %}
