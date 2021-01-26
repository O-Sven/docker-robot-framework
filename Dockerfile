FROM python:3.8-slim-buster

MAINTAINER Paul Podgorsek <ppodgorsek@users.noreply.github.com>
LABEL description Robot Framework in Docker.

# Set the reports directory environment variable
ENV ROBOT_REPORTS_DIR /opt/robotframework/reports

# Set the tests directory environment variable
ENV ROBOT_TESTS_DIR /opt/robotframework/tests

# Set the working directory environment variable
ENV ROBOT_WORK_DIR /opt/robotframework/temp

# Set ledsa path, should be overwritten in the yml file
ENV LEDSA_DIR /usr/local/lib/python3.8/site-packages/ledsa

# Setup X Window Virtual Framebuffer
ENV SCREEN_COLOUR_DEPTH 24
ENV SCREEN_HEIGHT 1080
ENV SCREEN_WIDTH 1920

# Set number of threads for parallel execution
# By default, no parallelisation
ENV ROBOT_THREADS 1

# Define the default user who'll run the tests
ENV ROBOT_UID 1000
ENV ROBOT_GID 1000

# Dependency versions
ENV ALPINE_GLIBC 2.31-r0
ENV CHROMIUM_VERSION 86.0
ENV DATABASE_LIBRARY_VERSION 1.2
ENV FAKER_VERSION 5.0.0
ENV FIREFOX_VERSION 78
ENV FTP_LIBRARY_VERSION 1.9
ENV GECKO_DRIVER_VERSION v0.26.0
ENV IMAP_LIBRARY_VERSION 0.3.6
ENV PABOT_VERSION 1.8.0
ENV REQUESTS_VERSION 0.7.0
ENV ROBOT_FRAMEWORK_VERSION 3.2
ENV SELENIUM_LIBRARY_VERSION 4.3.0
ENV SSH_LIBRARY_VERSION 3.4.0
ENV XVFB_VERSION 1.20

# Prepare binarie to be executed
COPY bin/run-tests-in-virtual-screen.sh /opt/robotframework/bin/

# Install system dependencies
RUN apt-get -y update \
  && apt-get -y upgrade \
  && apt-get -y install \
    gcc \
    libffi-dev \
    make \
    musl-dev \
    wget \
    xvfb \
#  && apt-get -y install \
#    xauth "xvfb-run~$XVFB_VERSION"\
#    "chromium~$CHROMIUM_VERSION" \
#    "chromium-chromedriver~$CHROMIUM_VERSION" \
#    "firefox-esr~$FIREFOX_VERSION" \
#  && mv /usr/lib/chromium/chrome /usr/lib/chromium/chrome-original \
#  && ln -sfv /opt/robotframework/bin/chromium-browser /usr/lib/chromium/chrome \
# FIXME: above is a workaround, as the path is ignored

# Install Robot Framework and Selenium Library
  && pip3 install \
    --no-cache-dir \
    robotframework==$ROBOT_FRAMEWORK_VERSION \
    robotframework-databaselibrary==$DATABASE_LIBRARY_VERSION \
    robotframework-faker==$FAKER_VERSION \
    robotframework-ftplibrary==$FTP_LIBRARY_VERSION \
    robotframework-imaplibrary2==$IMAP_LIBRARY_VERSION \
    robotframework-pabot==$PABOT_VERSION \
    robotframework-requests==$REQUESTS_VERSION \
    robotframework-seleniumlibrary==$SELENIUM_LIBRARY_VERSION \
    robotframework-sshlibrary==$SSH_LIBRARY_VERSION \
    PyYAML \
    
# Install Pyhton Libraries for the Tests
  && pip3 install --no-cache-dir numpy scipy Pillow matplotlib rawpy exifread

# Create the default report and work folders with the default user to avoid runtime issues
# These folders are writeable by anyone, to ensure the user can be changed on the command line.
RUN mkdir -p ${ROBOT_REPORTS_DIR} \
  && mkdir -p ${ROBOT_WORK_DIR} \
  && mkdir -p ${LEDSA_DIR} \
  && chown ${ROBOT_UID}:${ROBOT_GID} ${ROBOT_REPORTS_DIR} \
  && chown ${ROBOT_UID}:${ROBOT_GID} ${ROBOT_WORK_DIR} \
  && chown ${ROBOT_UID}:${ROBOT_GID} ${LEDSA_DIR} \
  && chmod ugo+w ${ROBOT_REPORTS_DIR} ${ROBOT_WORK_DIR} ${LEDSA_DIR}

# Allow any user to write logs
RUN chmod ugo+w /var/log \
  && chown ${ROBOT_UID}:${ROBOT_GID} /var/log

# Update system path
ENV PATH=/opt/robotframework/bin:/opt/robotframework/drivers:$PATH

# Set up a volume for the generated reports
VOLUME ${ROBOT_REPORTS_DIR}

USER ${ROBOT_UID}:${ROBOT_GID}

# A dedicated work folder to allow for the creation of temporary files
WORKDIR ${ROBOT_WORK_DIR}

# Execute all robot tests
CMD ["run-tests-in-virtual-screen.sh"]
