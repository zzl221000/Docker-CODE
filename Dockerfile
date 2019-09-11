FROM centos:7

# 这里改成你自己的域名，可改可不改
ENV domain localhost

#添加CODE的yum源
RUN rpm --import https://www.collaboraoffice.com/repos/CollaboraOnline/CODE-centos7/repodata/repomd.xml.key
RUN yum-config-manager --add-repo https://www.collaboraoffice.com/repos/CollaboraOnline/CODE-centos7

RUN yum update -y

#centos默认镜像中的glibc是精简过的，需要重新安装
RUN yum reinstall glibc glibc-common -y
#安装CODE
RUN yum install loolwsd CODE-brand -y
#安装启动脚本依赖的库
RUN yum install -y openssl perl 
#安装文泉译字体
# RUN yum install -y google-noto-cjk-fonts

#添加字体到系统指定目录
ADD windows /usr/share/fonts/windows
#重建字体缓存
RUN fc-cache -fv

#重点！/opt/lool/systemplate目录下需要将字体相关的几个文件夹重新用镜像中的对应文件夹覆盖，否则字体列表会有这个字体，但是实际上不生效
RUN rm -rf /opt/lool/systemplate/var/cache/fontconfig/*
RUN rm -rf /opt/lool/systemplate/usr/share/fonts/dejavu
# RUN cp /var/cache/fontconfig/* /opt/lool/systemplate/var/cache/fontconfig
RUN ln -snf /usr/share/fonts/* /opt/lool/systemplate/usr/share/fonts
RUN rm -rf /opt/lool/systemplate/etc/fonts
RUN cp -R /etc/fonts/ /opt/lool/systemplate/etc/fonts

# 设置环境变量为中文环境
RUN localedef -c -i zh_CN -f UTF-8 zh_CN.UTF-8
ENV LC_CTYPE zh_CN.UTF-8
ENV LC_ALL zh_CN.UTF-8
ENV LANG zh_CN.UTF-8
ADD scripts/start-libreoffice.sh /

# Entry point
CMD /bin/bash /start-libreoffice.sh
