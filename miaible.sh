# @author Louis Lee
# == 自定义配置 ==============================================

# 配置mqtt
mqtt_url="192.168.1.1"
mqtt_port=1883 
mqtt_topic="/miaibt/messages" 
mqtt_user="your_mqtt_username"
mqtt_password="your_mqtt_password"
# 小爱log地址
log_file="/tmp/log/messages"
# == /程序配置 ==============================================
lines=""
keyword="_async.ble_event"

echo "服务启动"

while true;do
  # 计算log文件行数
  new_lines=`wc -l ${log_file}|cut -d " " -f 1`
  [ -z ${lines} ] && lines=${new_lines}

  if [[ ${new_lines} -gt ${lines} ]];then
    start=`expr $lines + 1`
    lines=$new_lines
    temp=`tail -n +$start $log_file|grep ${keyword}|sed 's/.* rpc = //g'`
    for str in $temp; do
      mosquitto_pub -h ${mqtt_url} -p ${mqtt_port} -m "${temp}" -t "${mqtt_topic}" -u ${mqtt_user} -P ${mqtt_password} &
      echo 'send new ble event to mqtt successfully'
    done
  elif [ ${new_lines} -lt ${lines} ];then
    #重置
    lines=0
  fi
  sleep 0.000001
done
