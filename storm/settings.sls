{% set p = salt["pillar.get"]("storm", {}) %}
{% set pc = p.get("config", {}) %}
{% set g = salt["grains.get"]("storm", {})%}
{% set gc = g.get("config", {}) %}

{% set zmq_version = g.get("zmq_version", p.get("zmq_version", "4.1.3")) %}
{% set zmq_source_url = g.get("zmq_source_url", p.get("zmq_source_url", "http://download.zeromq.org/zeromq-"+ zmq_version +".tar.gz")) %}

{% set jzmq_version = g.get('jzmq_version', p.get('jzmq_version', '3.1.0')) %}
{% set jzmq_version_name = 'jzmq-' + jzmq_version %}

{% set jzmq_source_url = g.get('jzmq_source_url', p.get('jzmq_source_url',  "https://github.com/zeromq/jzmq/archive/v3.1.0.tar.gz")) %}

{% set version  = g.get("version", p.get("version", "0.10.0")) %}
{% set version_name = "storm-" + version %}
{% set zmq_version_name = "zeromq-" + zmq_version %}

{% set default_source_url = "http://www.us.apache.org/dist/storm/apache-storm-"+ version +"/apache-storm-"+ version +".tar.gz" %}
{% set default_source_url = "https://github.com/apache/storm/archive/v"+ version +".tar.gz"%}
{% set storm_source_url = g.get("source_url", p.get("source_url", default_source_url )) %}

{% set nimbus_host = g.get("nimbus", p.get("nimbus", "nimbus")) %}
{% set zookeeper_hosts = salt["pillar.get"]("zookeeper_hosts", "localhost:9092") %}

{% set user_name = g.get("user_name", p.get("user_name", "storm")) %}

{% set prefix = g.get("prefix", p.get("prefix", "/usr/local")) %}

{% set storm_real_home = prefix + "/" + version_name %}

{% set zmq_real_home = prefix + "/" + zmq_version_name  %}
{% set jzmq_real_home = prefix + "/" + jzmq_version_name  %}

{% set sodium_version = '1.0.7' %}
{% set sodium_source_url = 'https://download.libsodium.org/libsodium/releases/libsodium-1.0.7.tar.gz' %}
{% set sodium_sig_url = 'https://download.libsodium.org/libsodium/releases/libsodium-1.0.7.tar.gz.sig' %}
{% set sodium_version_name = 'libsodium-' + sodium_version %}
{% set sodium_real_home = prefix + '/' + sodium_version_name %}

{% set build_dir = prefix + "/source" %}




# merge the two config objects, Grains over Pillar
{% set config = pc %}
{% do config.update(gc) %}

{% set storm = salt['pillar.get']('storm:lookup', {}) %}
{% do storm.update({
  'version' : version,
  'nimbus_host': nimbus_host,
  'zookeeper_hosts': zookeeper_hosts,
  'prefix': prefix,
  'alt_home': prefix + '/storm',
  'real_home': storm_real_home,
  'log_dir': storm_real_home + '/log',
  'source_url': storm_source_url,
  'user_name': user_name,
  'build_dir': build_dir,
  'jvm_options': g.get('jvm_options', p.get('jvm_options', {})),
  'config': config,
  'config_dir': storm_real_home + '/conf'
}) %}

{% set zmq = salt['pillar.get']('storm:lookup:zmq', {}) %}
{% do zmq.update({
  'version': zmq_version,
  'version_name': zmq_version_name,
  'prefix': prefix,
  'alt_home': prefix + '/zmq',
  'real_home': zmq_real_home,
  'log_dir': '/var/log/zmq',
  'build_dir': build_dir,
  'source_url': zmq_source_url,
  'jzmq_version': jzmq_version,
  'jzmq_alt_home': prefix + '/jzmq',
  'jzmq_real_home': jzmq_real_home,
  'jzmq_source_url': jzmq_source_url,
  'jzmq_version_name': jzmq_version_name,
  'sodium_version': sodium_version,
  'sodium_version_name': sodium_version_name,
  'sodium_alt_home': prefix + '/libsodium',
  'sodium_real_home': sodium_real_home,
  'sodium_source_url': sodium_source_url
}) %}

