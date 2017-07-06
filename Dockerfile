FROM iarredondo/epics 
MAINTAINER Inigo Arredondo <inigo.arredondo@ehu.eus>

# Add Tini
ENV TINI_VERSION v0.15.0
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /tini
RUN chmod +x /tini

# Give the name for the softioc
ARG SOFT_IOC_NAME
ENV SOFT_IOC_NAME ${SOFT_IOC_NAME:-myioc}

RUN echo $USER

#Generate a soft-ioc
RUN  cd $WORK_DIR \
         && mkdir softioc \
         && cd softioc \
         && source ~/.bashrc \
         && makeBaseApp.pl -t example -a linux-x86_64 $SOFT_IOC_NAME \
         #&& makeBaseApp.pl -t ioc -a linux-x86_64 $SOFT_IOC_NAME \
         && makeBaseApp.pl -t example -i -a linux-x86_64 $SOFT_IOC_NAME 
         #&& makeBaseApp.pl -t ioc -i -a linux-x86_64 $SOFT_IOC_NAME 

#Copy your local db to the container
COPY ./db/ $WORK_DIR/softioc/db/ 

RUN  cd $WORK_DIR/softioc \
         && make 

#Create a run.sh script for CMD
RUN touch /usr/local/bin/epicsrun.sh
RUN echo "cd $WORK_DIR/softioc/iocBoot/$SOFT_IOC_NAME && ../../bin/linux-x86_64/$SOFT_IOC_NAME st.cmd" >> /usr/local/bin/epicsrun.sh
#Make it executable
RUN chmod 755 /usr/local/bin/epicsrun.sh

#Make the EPICS ports available
EXPOSE 5065 5064

#Run with tini
ENTRYPOINT ["/tini","-v", "--"]
CMD ["/usr/local/bin/epicsrun.sh"]
