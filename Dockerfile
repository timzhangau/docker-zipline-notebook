FROM python:3.5

#
# set up environment
#
ENV TINI_VERSION v0.10.0
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /tini
RUN chmod +x /tini
ENTRYPOINT ["/tini", "--"]

ENV PROJECT_DIR=/projects \
    NOTEBOOK_PORT=8888 \
    SSL_CERT_PEM=/root/.jupyter/jupyter.pem \
    SSL_CERT_KEY=/root/.jupyter/jupyter.key \
    # PW_HASH="u'sha1:31cb67870a35:1a2321318481f00b0efdf3d1f71af523d3ffc505'" \
    CONFIG_PATH=/root/.jupyter/jupyter_notebook_config.py \
    ZIPLINE_ROOT=/zipline

#
# install TA-Lib and other prerequisites
#
RUN mkdir ${PROJECT_DIR} \
    && apt-get -y update \
    && apt-get -y install libfreetype6-dev libpng-dev libopenblas-dev liblapack-dev gfortran libhdf5-dev \
    && curl -L https://downloads.sourceforge.net/project/ta-lib/ta-lib/0.4.0/ta-lib-0.4.0-src.tar.gz | tar xvz

#
# install TA-Lib after to ensure numpy is available.
#
WORKDIR /ta-lib

RUN pip install 'numpy>=1.11.1,<2.0.0' \
    && pip install 'scipy>=1.1.0,<1.10.0' \
    && pip install 'pandas>=0.18.1,<1.0.0' \
    && ./configure --prefix=/usr \
    && make \
    && make install \
    && pip install TA-Lib \
    && pip install matplotlib \
    && pip install jupyter


# install zipline and pyfolio
RUN pip install zipline \
    && pip install pyfolio

# ingest zipline quandl data
RUN zipline ingest -b quantopian-quandl

# hack to fix zipline missing benchmark data error
COPY ./zipline/benchmarks.py /usr/local/lib/python3.5/site-packages/zipline/data/benchmarks.py
COPY ./zipline/loader.py /usr/local/lib/python3.5/site-packages/zipline/data/loader.py

#
# docker start up cmd
#
ADD ./docker-cmd.sh /
RUN chmod +x /docker-cmd.sh

#
# make port available
#
EXPOSE ${NOTEBOOK_PORT}


#
# start the jupyter server
#
WORKDIR ${PROJECT_DIR}
CMD /docker-cmd.sh