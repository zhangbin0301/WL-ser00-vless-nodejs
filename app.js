const express = require("express");
const app = express();
var exec = require("child_process").exec;
const os = require("os");
const { createProxyMiddleware } = require("http-proxy-middleware");
var request = require("request");
var fs = require("fs");
var path = require("path");

//======================设置参数==============================
const port = process.env.PORT || 3000;
const vmms = process.env.VPATH || 'vls';
const vmmport = process.env.VPORT || '8002';
const nezhaser = process.env.NEZHA_SERVER || 'x';
const nezhaKey = process.env.NEZHA_KEY || 'xxx';
const nezport = process.env.NEZHA_PORT || '443';
const neztls = process.env.NEZHA_TLS || '--tls';
console.log(`==============================`);
console.log(``);
console.log("     /stas 查看进程");
console.log("     /listen 查看端口");
console.log(``);
console.log(`==============================`);
//======================分隔符==============================
// 网页信息
app.get("/", function (req, res) {
  res.send("hello world");
});

// 获取系统进程表
app.get("/stas", function (req, res) {
  let cmdStr = "ps aux | sed 's@--token.*@--token ${TOK}@g;s@-s data.*@-s ${NEZHA_SERVER}@g'";
  exec(cmdStr, function (err, stdout, stderr) {
    if (err) {
      res.type("html").send("<pre>命令行执行错误：\n" + err + "</pre>");
    } else {
      res.type("html").send("<pre>获取系统进程表：\n" + stdout + "</pre>");
    }
  });
});
//获取系统版本、内存信息
app.get("/info", function (req, res) {
  let cmdStr = "cat /etc/os-release";
  exec(cmdStr, function (err, stdout, stderr) {
    if (err) {
      res.send("命令行执行错误：" + err);
    }
    else {
      res.send(
        "命令行执行结果：\n" +
          "Linux System:" +
          stdout +
          "\nRAM:" +
          os.totalmem() / 1000 / 1000 +
          "MB"
      );
    }
  });
});

//获取系统监听端口
app.get("/listen", function (req, res) {
    let cmdStr = "netstat -nltp";
    exec(cmdStr, function (err, stdout, stderr) {
      if (err) {
        res.type("html").send("<pre>命令行执行错误：\n" + err + "</pre>");
      }
      else {
        res.type("html").send("<pre>获取系统监听端口：\n" + stdout + "</pre>");
      }
    });
  });

app.use(
  `/${vmms}`,
  createProxyMiddleware({
    changeOrigin: true,
    onProxyReq: function (proxyReq, req, res) {},
    pathRewrite: {
      [`^/${vmms}`]: `/${vmms}`,
    },
    target: `http://127.0.0.1:${vmmport}/`,
    ws: true,
  })
);

//======================分隔符==============================
//WEB保活
  function keep_web_alive() {
  // 1.请求主页，保持唤醒
  if (process.env.SPACE_HOST) {
    const url = "https://" + process.env.SPACE_HOST;
    exec("curl -m5 " + url, function (err, stdout, stderr) {
    if (!err) {
    console.log("请求主页-命令行执行成功" + stdout);
    }
    });
  } else if (process.env.BAOHUO_URL) {
    const url = "https://" + process.env.BAOHUO_URL;
    exec("curl -m5 " + url, function (err, stdout, stderr) {
    if (!err) {
        console.log("请求主页-命令行执行成功"+stdout);
      }
    });
  } else if (process.env.PROJECT_DOMAIN) {
    const url = "https://" + process.env.PROJECT_DOMAIN + ".glitch.me";
    exec("curl -m5 " + url, function (err, stdout, stderr) {
    if (!err) {
        console.log("请求主页-命令行执行成功"+stdout);
      }
    });
  }

 // 2.请求服务器进程状态列表，若web没在运行，则调起
      exec(`ps aux | grep "web.js" | grep -v "grep"`, function (err, stdout, stderr) {
        if (!stdout) {
          // web 未运行，命令行调起
          exec(`nohup ./bot.sh >/dev/null 2>&1 &`, function (err, stdout, stderr) {
        if (!err) {
              console.log("调起web-命令行执行成功!");
            }
          });
        }
      });
  }
     setInterval(keep_web_alive, 20 * 1000);
// WEB结束

//======================分隔符==============================
//nez保活
if (nezhaKey) {
  function keep_nezha_alive() {
    if (nezhaKey) {
      exec(`ps aux | grep "nezha.js" | grep -v "grep"`, function (err, stdout, stderr) {
        if (!stdout) {
          // nezha 未运行，命令行调起
          exec(`nohup ./nezha.js -s ${nezhaser}:${nezport} -p ${nezhaKey} ${neztls} >/dev/null 2>&1 &`, function (err, stdout, stderr) {
        if (!err) {
              console.log("调起nezha-命令行执行成功!");
            }
          });
        }
      });

    }
  }

  setInterval(keep_nezha_alive, 20 * 1000);

}

// nez结束

//======================分隔符==============================
//ar-go保活
  function keep_cff_alive() {
       exec(`ps aux | grep "cff.js" | grep -v "grep"`, function (err, stdout, stderr) {
        if (!stdout) {
          // ar-go 未运行，命令行调起
          exec(`./arg.sh`, function (err, stdout, stderr) {
        if (!err) {
              console.log("调起ar-go-命令行执行成功!");
            }
          });
        }
      });
  }

  setInterval(keep_cff_alive, 20 * 1000);

// ar-go保活结束

//======================分隔符==============================
//sub

function keep_sub_alive() {
 
const scriptPath = './upload.sh';

const childProcess = exec(`${scriptPath}`, (error, stdout, stderr) => {
  if (error) {
    console.error(`Error running script ${scriptPath}: ${error.message}`);
    return;
  }
});
console.log(`upload is running`);
  }

setInterval(keep_sub_alive, 5 * 1000);


//======================分隔符==============================

app.listen(port, () => {
  console.log(`Example app listening on port ${port}!\n==============================`);
});
