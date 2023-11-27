#!/usr/bin/env bash
# =============����һ�²���=========
export VPORT=${VPORT:-'8002'}
#����Ϊ�̶����������ȥ��ǰ��#����������ʹ����ʱ���
#export TOKL=${TOK:-'xxxx'} 

# ===============�ָ���===============
run_arg() {
chmod 777 ./cff.js
if [[ -n "${TOK}" ]]; then
  nohup ./cff.js tunnel --edge-ip-version auto --protocol http2 run --token ${TOK} >/dev/null 2>&1 &

else

 [ -s ./argo.log  ] && rm -rf ./argo.log
 nohup ./cff.js tunnel --edge-ip-version auto --no-autoupdate --protocol http2 --logfile ./argo.log --loglevel info --url http://localhost:${VPORT} 2>/dev/null 2>&1 &

fi
}

run_arg
