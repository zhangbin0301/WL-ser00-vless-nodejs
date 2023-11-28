#!/usr/bin/env bash
# =============设置一下参数=========
export VPORT=${VPORT:-'8808'}
export ACCESS_TOKEN="a3f85d208c161d"   # 请替换为您的实际访问密钥
#下面为固定隧道参数，去掉前面#，不设置则使用临时隧道
#export TOK=${TOK:-'xxxx'} 

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

export server_ip=$(curl -s https://ipinfo.io/ip)
export country_abbreviation=$(curl -s "https://ipinfo.io/${server_ip}/country")

# Check if country abbreviation exists and is in the correct format
if [[ -n "$country_abbreviation" && "$country_abbreviation" =~ ^[A-Z]{2}$ ]]; then
  echo "Successfully obtained valid country abbreviation: $country_abbreviation"
else
  # If not in the correct format or doesn't exist, try with access token
  
  country_abbreviation=$(curl -s "https://ipinfo.io/${server_ip}/country?token=${ACCESS_TOKEN}")

  # Check if country abbreviation exists and is in the correct format
  if [[ -n "$country_abbreviation" && "$country_abbreviation" =~ ^[A-Z]{2}$ ]]; then
    echo "Successfully obtained valid country abbreviation using token: $country_abbreviation"
  else
    echo "Country abbreviation is not in the correct format or couldn't be obtained. Defaulting to US."
    country_abbreviation="US"
  fi
fi

# Check again if country abbreviation is empty or not in the correct format
if [ -z "$country_abbreviation" ] || [[ ! "$country_abbreviation" =~ ^[A-Z]{2}$ ]]; then
  country_abbreviation="US"
fi

echo "country_abbreviation: $country_abbreviation" > ./guojia.yaml
