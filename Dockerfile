FROM arm32v7/debian:buster-slim
COPY qemu-arm-static /usr/bin
RUN apt-get update && apt-get install ca-certificates -y
COPY ./mycert.crt /usr/local/share/ca-certificates/mycert.crt
RUN update-ca-certificates
RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y \
        curl gnupg \
    && curl -L http://apt.mopidy.com/mopidy.gpg | apt-key add - \
    && curl -L http://apt.mopidy.com/mopidy.list -o /etc/apt/sources.list.d/mopidy.list \
    && apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y \
        mopidy \
        mopidy-scrobbler \
        mopidy-soundcloud \
        mopidy-spotify \
        mopidy-tunein \
        git \
        gstreamer1.0-libav \
        python-crypto \
        python-setuptools

RUN curl -L http://bootstrap.pypa.io/get-pip.py | python -
RUN pip install --ignore-installed Mopidy-Iris
RUN pip install -U six \
    && pip install markerlib \
    && pip install Mopidy-Local-SQLite \
    && pip install Mopidy-Local-Images \
    && pip install Mopidy-Party \
    && pip install Mopidy-Simple-Webclient \
    && pip install Mopidy-MusicBox-Webclient \
    && pip install Mopidy-API-Explorer \
    && pip install Mopidy-Mopify

#ADD snapserver.deb /tmp/snapserver.deb
#RUN apt-get install -y libavahi-client3 libavahi-common3 \
#    && dpkg -i /tmp/snapserver.deb \
#    && apt-get install -f \
#    && rm /tmp/snapserver.deb

ADD mopidy.conf /etc/mopidy.conf

ADD entrypoint.sh /entrypoint.sh

RUN chown mopidy:audio -R /var/lib/mopidy \
    && chown mopidy:audio /entrypoint.sh

ADD localscan /usr/bin/localscan
RUN chmod +x /usr/bin/localscan

VOLUME /var/lib/mopidy
VOLUME /media
VOLUME /mopidy.conf

EXPOSE 6600
EXPOSE 6680
EXPOSE 6681

USER mopidy

ENTRYPOINT ["/entrypoint.sh"]
CMD ["/usr/bin/mopidy"]
