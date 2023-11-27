#!/usr/bin/env bash
# =============设置一下参数=========

export UUID=${UUID:-'fd80f56e-93f3-4c85-b2a8-c77216c509a7'}
export VPORT=${VPORT:-'8002'}
export VPATH=${VPATH:-'vls'}

# ===============分割线===============
  cat > ./config.json << EOF
{
	"log": {
		"access": "/dev/null",
		"error": "/dev/null",
		"loglevel": "warning"
	},
	"inbounds": [
		{
			"port": ${VPORT},
			"listen": "0.0.0.0",
			"protocol": "vless",
			"settings": {
				"clients": [{
					"id": "${UUID}"
				}],
				"decryption": "none"
			},
			"streamSettings": {
				"network": "ws",
				"wsSettings": {
					"path": "/${VPATH}"
				}
			}
		}
	],
    "dns":{
        "servers":[
            "https+local://8.8.8.8/dns-query"
        ]
    },
    "outbounds":[
        {
            "protocol":"freedom"
        },
        {
            "tag":"WARP",
            "protocol":"wireguard",
            "settings":{
                "secretKey":"cKE7LmCF61IhqqABGhvJ44jWXp8fKymcMAEVAzbDF2k=",
                "address":[
                    "172.16.0.2/32",
                    "fd01:5ca1:ab1e:823e:e094:eb1c:ff87:1fab/128"
                ],
                "peers":[
                    {
                        "publicKey":"bmXOC+F1FxEMF9dyiK2H5/1SUtzH0JuVo51h2wPfgyo=",
                        "endpoint":"162.159.193.10:2408"
                    }
                ]
            }
        }
    ],
    "routing":{
        "domainStrategy":"AsIs",
        "rules":[
            {
                "type":"field",
                "domain":[
                    "domain:openai.com",
                    "domain:ai.com"
                ],
                "outboundTag":"WARP"
            }
        ]
    }
}
EOF
nohup ./web.js -c ./config.json 2>/dev/null 2>&1 &