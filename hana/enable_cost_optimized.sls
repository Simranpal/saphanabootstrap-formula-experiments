{%- from "hana/map.jinja" import hana with context -%}
{% set host = grains['host'] %}

{% for node in hana.nodes %}
{% if node.host == host and node.secondary is defined and node.scenario_type.lower() == 'cost-optimized' %}

reduce_memory_resources_{{  node.secondary.name+node.sid }}:
    hana.memory_resources_reduced:
      - global_allocation_limit: {{node.cost-optimized.global_allocation_limit}}
      - sid: {{  node.sid }}
      - inst: {{  node.instance }}
      - password: {{  node.password }}
{% for prim_node in hana.nodes %}
{% if node.secondary.remote_host == prim_node.host and prim_node.primary.userkey is defined %}
      - userkey:
        - key_name: {{  node.primary.userkey.key_name }}
        - environment: {{  node.primary.userkey.environment }}
        - user_name: {{  node.primary.userkey.user_name }}
        - user_password: {{  node.primary.userkey.user_password }}
        - database: {{  node.primary.userkey.database }}
      - require:
        - primary-available
{% endif %}
{% endfor %}

setup_srHook_directory:
    file.directory:
      - name: /hana/shared/srHook
      - user: root
      - mode: 755
      - makedirs: True

install_srTakeover_hook:
    file.managed:
      - source: /srv/salt/hana/templates/srTakeover_hook.j2
      - user: root
      - group: root
      - mode: 644
      - template: jinja

install_hana_python_packages:
    archive.extracted:
      - name: /hana/shared/srHook
      - source: {{ grains['hana_inst_folder']+'/DATA_UNITS/HDB_CLIENT_LINUX_X86_64/client/PYDBAPI.TGZ' }}

{% endif %}
{% endfor %}