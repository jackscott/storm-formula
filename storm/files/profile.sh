#!/bin/bash
{%- from "storm/map.jinja" import meta,config with context %}
[[ ":$PATH:" == *":{{ meta.bin_dir }}:"* ]] || export PATH=$PATH:{{ meta.bin_dir }}
export JAVA_HOME={{ meta.java_home }}
export STORM_LOCAL_CACHE={{ local_cache }}
export STORM_CONFIG_DIR={{ meta.conf_dir }}
