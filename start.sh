#!/usr/bin/env bash
## Entry point for the Tomcat container.
##

set -e

debugging=false

xx() {
	echo "+" "$@"
	"$@"
}

printenv_sorted() {
	xx printenv | xx env LC_ALL=C sort
}

sync_directory_pair() { # d1 d2
	local d1="${1:?}"
	local d2="${2:?}"

	xx mkdir -p "$d1"
	xx mkdir -p "$d2"

	(xx cd "$d1" && xx cp -r . "$d2"/.)
	(xx cd "$d2" && xx cp -r . "$d1"/.)
}

##

tomcat_docker_image_user_name="${tomcat_docker_image_user_name:-root}"
tomcat_docker_image_group_name="${tomcat_docker_image_group_name:-root}"

tomcat_docker_image_conf_root="${tomcat_docker_image_conf_root:-/usr/local/tomcat/conf}"
tomcat_docker_image_webapps_root="${tomcat_docker_image_webapps_root:-/usr/local/tomcat/webapps}"

tomcat_docker_image_ref_conf_root="${tomcat_docker_image_ref_conf_root:-/var/local/workspaces/tomcat.ref/conf}"
tomcat_docker_image_ref_webapps_root="${tomcat_docker_image_ref_webapps_root:-/var/local/workspaces/tomcat.ref/webapps}"

tomcat_docker_image_setup_root="${tomcat_docker_image_setup_root:-/var/local/workspaces/tomcat/setup}"

##

xx :
sync_directory_pair "${tomcat_docker_image_ref_conf_root}" "${tomcat_docker_image_conf_root}"

xx :
sync_directory_pair "${tomcat_docker_image_ref_webapps_root}" "${tomcat_docker_image_webapps_root}"

##

export TINI_SUBREAPER=
#^-- mere existence indicates 'true'

echo
echo "Environment variables:"
xx :
printenv_sorted

##

tomcat="${CATALINA_HOME}/bin/catalina.sh"
action=run

xx :
xx cd "${CATALINA_HOME}"
xx pwd

if ${debugging} ; then
	echo
	echo "Launching a shell..."
	xx :
	xx exec bash -l
else
	echo
	echo "Launching Tomcat ${TOMCAT_VERSION}..."
	xx :
	xx exec "${tomcat}" "${action}" "$@"
##	xx exec tini -- "${tomcat}" "${action}" "$@"
fi

##

