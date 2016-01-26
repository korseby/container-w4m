FROM debian

MAINTAINER Kristian Peters <kpeters@ipb-halle.de>

LABEL Description="Install W4M GALAXY in Docker."

# add cran R backport
RUN apt-key adv --keyserver keys.gnupg.net --recv-key 381BA480
RUN echo "deb http://cran.uni-muenster.de/bin/linux/debian jessie-cran3/" >> /etc/apt/sources.list

# update & upgrade sources
RUN apt-get -y update
RUN apt-get -y dist-upgrade

# install packages
RUN apt-get -y install r-base gnuplot5 netcdf-bin libnetcdf-dev libdigest-sha-perl 

# install development files needed
RUN apt-get -y install git python xorg-dev libglu1-mesa-dev freeglut3-dev libgomp1 libxml2-dev gcc-4.9 g++-4.9 libgfortran-4.9-dev libcurl4-gnutls-dev
RUN update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-4.9 50
RUN update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-4.9 50
RUN update-alternatives --install /usr/bin/cpp cpp /usr/bin/cpp-4.9 50

# clean up
RUN apt-get -y clean && apt-get -y autoremove && rm -rf /var/lib/{cache,log}/ /tmp/* /var/tmp/*

# install GALAXY
RUN cd /usr/src; git clone https://github.com/galaxyproject/galaxy; cd galaxy; git checkout -b release_15.10 origin/release_15.10

# generate GALAXY config
RUN echo '[server:main]' >> /usr/src/galaxy/config/galaxy.ini
RUN echo 'use = egg:Paste#http' >> /usr/src/galaxy/config/galaxy.ini
RUN echo 'port = 8889' >> /usr/src/galaxy/config/galaxy.ini
RUN echo 'host = 0.0.0.0' >> /usr/src/galaxy/config/galaxy.ini
RUN echo 'use_threadpool = True' >> /usr/src/galaxy/config/galaxy.ini
RUN echo '[filter:gzip]' >> /usr/src/galaxy/config/galaxy.ini
RUN echo 'use = egg:Paste#gzip' >> /usr/src/galaxy/config/galaxy.ini
RUN echo '[filter:proxy-prefix]' >> /usr/src/galaxy/config/galaxy.ini
RUN echo 'use = egg:PasteDeploy#prefix' >> /usr/src/galaxy/config/galaxy.ini
RUN echo 'prefix = /galaxy' >> /usr/src/galaxy/config/galaxy.ini
RUN echo '[app:main]' >> /usr/src/galaxy/config/galaxy.ini
RUN echo 'paste.app_factory = galaxy.web.buildapp:app_factory' >> /usr/src/galaxy/config/galaxy.ini

# Expose port to outside
EXPOSE 8889

# Define Entry point script
ENTRYPOINT ["/bin/sh","/usr/src/galaxy/run.sh"]

