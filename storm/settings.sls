
{% set p = salt["pillar.get"]("storm", {}) %}
{% set pc = p.get("config", {}) %}
{% set g = salt["grains.get"]("storm", {})%}
{% set gc = g.get("config", {}) %}

{% set zmq_version = g.get("zmq_version", p.get("zmq_version", "4.1.3")) %}
{% set zmq_source_url = g.get("zmq_source_url", p.get("zmq_source_url", "http://download.zeromq.org/zeromq-4.1.3.tar.gz")) %}

{% set jzmq_version = g.get('jzmq_version', p.get('jzmq_version', '3.1.0')) %}
{% set jzmq_version_name = 'jzmq-' + jzmq_version %}

{% set jzmq_source_url = g.get('jzmq_source_url', p.get('jzmq_source_url',  "https://github.com/zeromq/jzmq/archive/v3.1.0.tar.gz") %}

{% set version  = g.get("version", p.get("version", "0.10.0")) %}
{% set version_name = "storm-" + version %}
{% set zmq_version_name = "zmq" + zmq_version %}

{% set default_source_url = "https://github.com/apache/storm/archive/v"+ version +".tar.gz"%}
{% set storm_source_url = g.get("source_url", p.get("source_url", default_source_url )) %}

{% set nimbus_host = g.get("nimbus", p.get("nimbus", "nimbus")) %}
{% set zookeeper_hosts = salt["pillar.get"]("zookeeper_hosts", "localhost:9092") %}

{% set user_name = g.get("user_name", p.get("user_name", "storm")) %}

{% set prefix = g.get("prefix", p.get("prefix", "/usr/lib")) %}

{% set storm_real_home = prefix + "/" + version_name %}

{% set zmq_real_home = prefix + "/" + zmq_version_name  %}
{% set jzmq_real_home = prefix + "/" + jzmq_version_name  %}

{% set storm = {} %}
{% set zmq = {} %}

{% do storm.update({
  'version' : version,
  'nimbus_host': nimbus_host,
  'zookeeper_hosts': zookeeper_hosts,
  'prefix': prefix,
  'real_home': storm_real_home
  'log_dir': storm_real_home + '/log',
  'source_url': storm_source_url
}) %}

{% do zmq.update({
  'version': zmq_version,
  'prefix': prefix,
  'real_home': zmq_real_home,
  'log_dir': '/var/log/zmq',
  'source_url': zmq_source_url,
  'jzmq_version': jzmq_version,
  'jzmq_real_home': jzmq_real_home
  
}) %}

