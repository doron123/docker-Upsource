FROM esycat/java:oracle-8

MAINTAINER "Doron Chen" <doron@JaaSun.com>

ENV APP_VERSION 2.0
ENV APP_BUILD ${APP_VERSION}.3682
ENV APP_PORT 32769
ENV APP_USER upsource
ENV APP_SUFFIX upsource

ENV APP_DISTFILE upsource-${APP_BUILD}.zip
ENV APP_PREFIX /opt
ENV APP_DIR $APP_PREFIX/$APP_SUFFIX
ENV APP_HOME /var/lib/$APP_SUFFIX

# downloading and unpacking the distribution
WORKDIR $APP_PREFIX
ADD https://download.jetbrains.com/upsource/$APP_DISTFILE $APP_PREFIX/
# COPY $APP_DISTFILE $APP_PREFIX/
RUN unzip $APP_DISTFILE
RUN rm $APP_DISTFILE
RUN mv Upsource $APP_SUFFIX

# removing bundled JVMs
RUN rm -rf $APP_DIR/internal/java

# preparing home (data) directory and user+group
RUN mkdir $APP_HOME
RUN groupadd -r $APP_USER
RUN useradd -r -g $APP_USER -d $APP_HOME $APP_USER
RUN chown -R $APP_USER:$APP_USER $APP_HOME $APP_DIR

USER $APP_USER
WORKDIR $APP_DIR

RUN bin/upsource.sh configure \
    --backups-dir $APP_HOME/backups \
    --data-dir    $APP_HOME/data \
    --logs-dir    $APP_HOME/log \
    --temp-dir    $APP_HOME/tmp \
    --listen-port $APP_PORT \
    --base-url    http://localhost/

ENTRYPOINT ["bin/upsource.sh"]
CMD ["run"]
EXPOSE $APP_PORT
VOLUME ["$APP_HOME"]
