#!/usr/bin/env bash
#设置如下参数
export UUID=${UUID:-'fd80f56e-93f3-4c85-b2a8-c77216c509a7'}
export VPATH=${VPATH:-'vls'}
export CF_IP=${CF_IP:-'ip.sb'}
export SUB_NAME=${SUB_NAME:-'serv002'}
export SUB_URL=${SUB_URL:-'ip.sb'}

# 上传订阅
upload_url_data() {
    if [ $# -lt 3 ]; then
        return 1
    fi

    UPLOAD_URL="$1"
    URL_NAME="$2"
    URL_TO_UPLOAD="$3"

    # 检查curl命令是否存在
    if command -v curl &> /dev/null; then

       curl -s -o /dev/null -X POST -H "Content-Type: application/json" -d "{\"URL_NAME\": \"$URL_NAME\", \"URL\": \"$URL_TO_UPLOAD\"}" "$UPLOAD_URL"

    # 检查wget命令是否存在
    elif command -v wget &> /dev/null; then

        echo "{\"URL_NAME\": \"$URL_NAME\", \"URL\": \"$URL_TO_UPLOAD\"}" | wget --quiet --post-data=- --header="Content-Type: application/json" "$UPLOAD_URL" -O -

    else
        echo "Both curl and wget are not installed. Please install one of them to upload data."
    fi
}


if [[ -z "${TOK}" ]]; then
  [ -s ./argo.log ] && export ARGO_DOMAIN=$(cat ./argo.log | grep -o "info.*https://.*trycloudflare.com" | sed "s@.*https://@@g" | tail -n 1)
fi

export server_ip=$(curl -s https://ipinfo.io/ip)

export country_abbreviation=$(curl -s https://ipinfo.io/${server_ip}/country)
export V_URL="{PASS}://${UUID}@${CF_IP}:443?host=${ARGO_DOMAIN}&path=%2F${VPATH}%3Fed%3D2048&type=ws&encryption=none&security=tls&sni=${ARGO_DOMAIN}#{PASS}-${country_abbreviation}-${SUB_NAME}"

if [[ -n "${SUB_URL}" ]]; then
  upload_url_data "${SUB_URL}" "${SUB_NAME}" "${V_URL}"
fi
