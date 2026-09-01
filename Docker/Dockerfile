FROM ubuntu:24.04
ENV DEBIAN_FRONTEND=noninteractive
ARG APT_COMMAND="apt-get -o Acquire::Retries=3 -y"
ENV HOME=/home

RUN ${APT_COMMAND} update && ${APT_COMMAND} install build-essential \
    gtk2.0 libgtk2.0-dev tcl8.6 tcl8.6-dev libgsl-dev libsuitesparse-dev \
    libfftw3-dev libreadline-dev flex bison software-properties-common wget checkinstall cmake gnuplot \
    libncursesw5-dev libssl-dev libsqlite3-dev tk-dev libgdbm-dev libc6-dev libbz2-dev libffi-dev zlib1g-dev libvte-dev p7zip-full git

RUN cp /usr/include/tcl8.6/* /usr/include/ -r

# Must match Docker/Makefile's bind-mount target (LIBREEDA_ROOT_PATH).
# Needs ENV, not RUN export -- export doesn't persist past its own layer.
ENV LibreEDA_INSTALL_DIR=/home/LibreEDA-Project/Tool/build
ENV LIBREEDA_ROOT=/home/LibreEDA-Project/Tool/build

WORKDIR /home/
CMD ["/bin/bash"]