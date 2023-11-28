#!/usr/bin/env bash
# =============设置一下参数====改端口=====
export VPORT=${VPORT:-'8808'}
#下面为固定隧道参数，去掉前面#，不设置则使用临时隧道
#export TOKL=${TOK:-'xxxx'} 
#export ARGO_DOMAIN=${ARGO_DOMAIN:-'xxxx'}

# ===============分割线===============
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
