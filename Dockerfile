FROM kbase/kbase:sdkbase.latest
MAINTAINER KBase Developer
# -----------------------------------------
# In this section, you can install any system dependencies required
# to run your App.  For instance, you could place an apt-get update or
# install line here, a git checkout to download code, or run any other
# installation scripts.

#RUN apt-get update

# Here we install a python coverage tool and an
# https library that is out of date in the base image.

RUN pip install coverage

# Solve the "Could not find .egg-info directory, etc."
RUN pip install --upgrade setuptools pip

# update security libraries in the base image
RUN pip install cffi --upgrade \
    && pip install pyopenssl --upgrade \
    && pip install ndg-httpsclient --upgrade \
    && pip install pyasn1 --upgrade \
    && pip install requests --upgrade \
    && pip install 'requests[security]' --upgrade


# Install xvfb for matplotlib pdfs
#    apt-get -y install xvfb
RUN apt-get update && \
    apt-get -y install xvfb python-qt4


# For kaiju bin
WORKDIR /kb/module
RUN \
    git clone https://github.com/bioinformatics-centre/kaiju.git && \
    cd kaiju/src && \
    make

# For Krona Tools
WORKDIR /kb/module
RUN \
    git clone https://github.com/marbl/Krona && \
    cd Krona/KronaTools && \
    ./install.pl
#    ./install.pl && \
#    mkdir taxonomy && \
#    ./updateTaxonomy.sh && \
#    ./updateAccessions.sh

# For kaiju dbs (rest of db installation to ref data mount in entrypoint.sh init script)
RUN mkdir -p /data/kaijudb


# -----------------------------------------

COPY ./ /kb/module
RUN mkdir -p /kb/module/work
RUN chmod -R a+rw /kb/module

WORKDIR /kb/module

RUN make all

ENTRYPOINT [ "./scripts/entrypoint.sh" ]

CMD [ ]