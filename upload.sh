#!/usr/bin/env bash
#设置如下参数,改容器名称
export UUID=${UUID:-'ea4909ef-7ca6-4b46-bf2e-6c07896ef338'}
export VPATH=${VPATH:-'vls'}
export CF_IP=${CF_IP:-'www.jjtyss.com'}
export SUB_NAME=${SUB_NAME:-'serv00.net-ice'}
export SUB_URL=${SUB_URL:-'https://newbirds-sub.hf.space/upload-ea4909ef-7ca6-4b46-bf2e-6c07896ef338'}

#固定隧道需要设置域名
#export ARGO_DOMAIN=${ARGO_DOMAIN:-'xxxxxx'}


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

if [ -s "./guojia.yaml" ]; then
  country_abbreviation=$(cat "./guojia.yaml" | grep "country_abbreviation" | cut -d ' ' -f2)
  echo "国家简称已从文件中读取: $country_abbreviation"
else
  echo "提示: ./guojia.yaml 不存在或为空。"
  country_abbreviation="JOKE"
fi

export V_URL="{PASS}://${UUID}@${CF_IP}:443?host=${ARGO_DOMAIN}&path=%2F${VPATH}%3Fed%3D2048&type=ws&encryption=none&security=tls&sni=${ARGO_DOMAIN}#{PASS}-${country_abbreviation}-${SUB_NAME}"
echo "${V_URL}" > ./list.log
if [[ -n "${SUB_URL}" ]]; then
  upload_url_data "${SUB_URL}" "${SUB_NAME}" "${V_URL}"
fi
