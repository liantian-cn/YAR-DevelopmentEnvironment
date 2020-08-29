FROM alpine:latest

############################################################
# 基本目录
# /app      程序路径
# /static   静态文件路径
# /run      文件路径
# /media    上传文件路径
# /database sqlite数据库路径
# /log      日志文件路径
############################################################


RUN mkdir -p /app  \
&& mkdir -p /run  \
&& mkdir -p /static \
&& mkdir -p /media \
&& mkdir -p /database \
&& mkdir -p /log 

############################################################
# 安装 基础组件
############################################################

RUN  sed -i 's/dl-cdn.alpinelinux.org/mirrors.tuna.tsinghua.edu.cn/g' /etc/apk/repositories  \
&& apk update \
&& apk add --no-cache bash  bash-doc bash-completion nano supervisor \
&& rm /etc/supervisord.conf \
&& mkdir /etc/supervisor.d/ \
&& mkdir /log/supervisord/
COPY supervisord.conf /etc/

############################################################
# 安装 SSH
# 将配置root账号密码为Aa@123456
############################################################

RUN apk add --no-cache openssh tzdata   \
&& cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
&& sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config \
&& ssh-keygen -t dsa -P "" -f /etc/ssh/ssh_host_dsa_key \
&& ssh-keygen -t rsa -P "" -f /etc/ssh/ssh_host_rsa_key  \
&& ssh-keygen -t ecdsa -P "" -f /etc/ssh/ssh_host_ecdsa_key  \
&& ssh-keygen -t ed25519 -P "" -f /etc/ssh/ssh_host_ed25519_key  \
&& echo "root:Aa@123456" | chpasswd
COPY sshd.ini /etc/supervisor.d/

############################################################
# 安装 Python , 同时安装pip，设置为清华源。
############################################################

RUN apk add --no-cache python3 py3-pip py3-setuptools \
&& pip3 config set global.index-url https://pypi.tuna.tsinghua.edu.cn/simple \
&& ln -s /usr/bin/python3 /usr/bin/python


############################################################
# 安装 redis
# redis监听unix端口 /var/run/redis/redis.sock
# 不监听任何tcp端口，仅作缓存
############################################################

RUN apk add --no-cache redis 
RUN rm /etc/redis.conf 
COPY redis.conf /etc/
COPY redis.ini /etc/supervisor.d/

############################################################
# 安装 项目依赖
############################################################

RUN apk add --no-cache py3-pillow  py3-ldap3  py3-psycopg2   \
&& pip3 install --no-cache-dir django django-debug-toolbar django-rq django-redis 


############################################################
# 清理缓存
############################################################


RUN rm -rf /var/cache/apk/* 


EXPOSE 22 80 443 8000 8080 8443 


CMD ["/usr/bin/supervisord"]




