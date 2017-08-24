FROM tomcat:8.5.16-jre8

STOPSIGNAL SIGTERM

ENV tomcat_docker_image_conf_root=/usr/local/tomcat/conf
ENV tomcat_docker_image_webapps_root=/usr/local/tomcat/webapps
#^-- specified by the base image

ENV tomcat_docker_image_ref_conf_root=/var/local/workspaces/tomcat.ref/conf
ENV tomcat_docker_image_ref_webapps_root=/var/local/workspaces/tomcat.ref/webapps

ENV tomcat_docker_image_setup_root=/var/local/workspaces/tomcat/setup

VOLUME [ "$tomcat_docker_image_ref_conf_root" ]
VOLUME [ "$tomcat_docker_image_ref_webapps_root" ]

##

USER    root
WORKDIR "${tomcat_docker_image_setup_root}"

COPY packages.needed.01.txt .
RUN  egrep -v '^\s*#' packages.needed.01.txt > packages.needed.01.filtered.txt

RUN apt-get update && apt-get install -y apt-utils && \
	apt-get install -y $(cat packages.needed.01.filtered.txt) && \
	rm -rf /var/lib/apt/lists/* ;

##

USER    root
WORKDIR "${tomcat_docker_image_setup_root}"

COPY start.sh .

ENTRYPOINT ["sh", "start.sh"]

##

