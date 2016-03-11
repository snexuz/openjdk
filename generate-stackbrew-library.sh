#!/bin/bash
set -e

declare -A aliases
aliases=(
	[8-jdk]='jdk latest'
	[8-jre]='jre'
)
defaultType='jdk'

cd "$(dirname "$(readlink -f "$BASH_SOURCE")")"

versions=( */ )
versions=( "${versions[@]%/}" )
url='git://github.com/docker-library/openjdk'

echo '# maintainer: InfoSiftr <github@infosiftr.com> (@infosiftr)'

for version in "${versions[@]}"; do
	commit="$(cd "$version" && git log -1 --format='format:%H' -- Dockerfile $(awk 'toupper($1) == "COPY" { for (i = 2; i < NF; i++) { print $i } }' Dockerfile))"
	
	javaVersion="$version" # "6-jdk"
	javaType="${javaVersion##*-}" # "jdk"
	javaVersion="${javaVersion%-*}" # "6"
	
	fullVersion="$(grep -m1 'ENV JAVA_VERSION ' "$version/Dockerfile" | cut -d' ' -f3 | tr '~' '-')"
	
	bases=( $fullVersion )
	if [ "${fullVersion%-*}" != "$fullVersion" ]; then
		bases+=( ${fullVersion%-*} ) # like "8u40-b09
	fi
	if [ "$javaVersion" != "${fullVersion%-*}" ]; then
		bases+=( $javaVersion )
	fi
	bases=( "${bases[@]/#/openjdk-}" "${bases[@]}" )
	
	versionAliases=()
	for base in "${bases[@]}"; do
		versionAliases+=( "$base-$javaType" )
		if [ "$javaType" = "$defaultType" ]; then
			versionAliases+=( "$base" )
		fi
	done
	versionAliases+=( ${aliases[$version]} )
	
	echo
	for va in "${versionAliases[@]}"; do
		echo "$va: ${url}@${commit} $version"
	done
done
