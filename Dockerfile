FROM iarredondo/epics as builder
LABEL authors="Inigo Arredondo <inigo.arredondo@ehu.eus>, Dan Thomson <dthomson@triumf.ca>"

# Security update this guy
# RUN yum -y update

# Add Tini
ENV TINI_VERSION v0.15.0
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /tini
RUN chmod +x /tini

# Give the name for the softioc
ARG SOFT_IOC_NAME
ENV SOFT_IOC_NAME ${SOFT_IOC_NAME:-myioc}
ENV WORK_DIR ${WORK_DIR:-/usr/local/epics}
ENV APPLICATION_TYPE ${APPLICATION_TYPE:-example}

# Generate a soft-ioc
RUN cd $WORK_DIR \
         && mkdir softioc \
         && cd softioc \
         && source ~/.bashrc \
         && makeBaseApp.pl -t $APPLICATION_TYPE -a linux-x86_64 $SOFT_IOC_NAME \
         #&& makeBaseApp.pl -t ioc -a linux-x86_64 $SOFT_IOC_NAME \
         && makeBaseApp.pl -t $APPLICATION_TYPE -i -a linux-x86_64 $SOFT_IOC_NAME 
         #&& makeBaseApp.pl -t ioc -i -a linux-x86_64 $SOFT_IOC_NAME 

# Copy your local db to the container
# COPY ./db/ $WORK_DIR/softioc/db/

RUN cd $WORK_DIR/softioc \
         && make

FROM builder AS runner

COPY usr/local/bin/docker-entrypoint.sh /usr/local/bin
RUN chmod 755 /usr/local/bin/docker-entrypoint.sh && \
	ln -s /usr/local/bin/docker-entrypoint.sh /docker-entrypoint.sh

# Make the EPICS ports available
EXPOSE 5065 5064

# Run with tini
ENTRYPOINT "/usr/local/bin/docker-entrypoint.sh"
