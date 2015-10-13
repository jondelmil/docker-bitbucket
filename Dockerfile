FROM azul/zulu-openjdk-debian:latest
MAINTAINER Jon Miller <jondelmil@gmail.com>

# Configuration
ENV BITBUCKET_HOME /data/bitbucket
ENV BITBUCKET_VERSION 4.0.2

# Install dependencies
RUN apt-get update && apt-get install -y \
	git \
	curl \
	tar \
	xmlstarlet

# Create the user that will run the bitbucket instance and his home directory (also make sure that the parent directory exists)
RUN mkdir -p $(dirname $BITBUCKET_HOME) \
	&& useradd -m -d $BITBUCKET_HOME -s /bin/bash -u 782 bitbucket

# Download and install bitbucket in /opt with proper permissions and clean unnecessary files
# (Still "stash" in Atlassian's download URL)
RUN curl -Lks http://www.atlassian.com/software/stash/downloads/binary/atlassian-bitbucket-$BITBUCKET_VERSION.tar.gz -o /tmp/bitbucket.tar.gz \
	&& mkdir -p /opt/bitbucket \
	&& tar -zxf /tmp/bitbucket.tar.gz --strip=1 -C /opt/bitbucket \
	&& chown -R root:root /opt/bitbucket \
	&& chown -R 782:root /opt/bitbucket/logs /opt/bitbucket/temp /opt/bitbucket/work \
	&& rm /tmp/bitbucket.tar.gz

# Add bitbucket customizer and launcher
COPY launch.sh /launch

# Make bitbucket customizer and launcher executable
RUN chmod +x /launch

# Expose ports
EXPOSE 7990 7999

# Workdir
WORKDIR /opt/bitbucket

# Launch bitbucket
ENTRYPOINT ["/launch"]
