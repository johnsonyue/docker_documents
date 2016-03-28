#docker1.9及以上的安装和部署：
##安装需要满足条件:
docker 1.9需要内核4.3.3及以上来支持overlay网络。
需要64位Linux操作系统。

##安装：
参考docker官方文档的安装教程，https://docs.docker.com/linux/step_one/，


##部署前的准备：
        1.按照脚本使用说明，写好配置文件。
        2.从镜像仓储下载用到的镜像。
        3.把打包的代码和数据解压到配置文件所写的位置。
        4.参考shipyard的swarm搭建教程，搭建swarm。(教程中不需要proxy) http://shipyard-project.com/docs/deploy/manual/
        5.在搭建好的swarm中新建overlay网络，如：docker -H 173.26.102.10:3476 network create vxlan0 (端口号是根据第四步中的swarm-manager来确定的)
		6.使用脚本前，将file, gateway变量赋值为正确值(file是iptables-save导出的文件路径，gateway是docker网桥的ip)
		7.在分配容器外网ip之前，确保已经创建具有该ip的虚拟接口。

##批量部署：
按照脚本使用说明，执行脚本。例如: ./ctnr_ctrl.sh creat config


#docker 1.9脚本使用说明：
##用法: 
./ctnr_ctrl.sh <操作> <配置文件>
###操作:
    create 根据指定的配置文件创建一个容器。
            
    start 启动一个处在exited状态的容器。
            
    stop 停止一个正在运行的容器。
            
    rm 停止并删除一个正在运行的容器。
            
    pause 暂停一个容器上的进程。
            
    unpause 取消容器上对进程的暂停。
            

###配置文件格式: 
    每一行包含如下字段：容器名  overlay网络  外网ip  端口  卷  镜像  启动命令
            
    容器名(必须，唯一):分配给容器的标识符。
            
    overlay网络(可选，唯一): 用于容器间通信的网络。
            
    外网ip(可选，唯一): 分配各容器的外网ip(外网用来访问容器的ip)。
            
    端口(可选，可多个): 容器暴露给外部的端口。用':'作为多个端口的分隔符。如果是udp需要在端口号后加上/udp。
            
    卷(可选，可多个): 指定宿主机挂载到容器中的卷。格式为："宿主机卷:容器卷"。多个之间用’,’作为分隔符。
            
    镜像(必须，唯一): 容器建立的基础镜像。
            
    命令(必须，唯一): 容器建立时执行的第一条命令(通常为/bin/bash)。
    