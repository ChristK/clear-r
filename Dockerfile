FROM clearlinux:latest AS builder
LABEL maintainer "Chris Kypridemos <ckyprid@liverpool.ac.uk>"

ARG swupd_args
# Move to latest Clear Linux release to ensure
# that the swupd command line arguments are
# correct
RUN swupd update --no-boot-update $swupd_args

# Grab os-release info from the minimal base image so
# that the new content matches the exact OS version
COPY --from=clearlinux/os-core:latest /usr/lib/os-release /

# Install additional content in a target directory
# using the os version from the minimal base
RUN source /os-release && \
    mkdir /install_root \
    && swupd os-install -V ${VERSION_ID} \
    --path /install_root --statedir /swupd-state \
    --bundles=os-core-update,R-extras-dev --no-boot-update

# For some Host OS configuration with redirect_dir on,
# extra data are saved on the upper layer when the same
# file exists on different layers. To minimize docker
# image size, remove the overlapped files before copy.
RUN mkdir /os_core_install
COPY --from=clearlinux/os-core:latest / /os_core_install/
RUN cd / && \
    find os_core_install | sed -e 's/os_core_install/install_root/' | xargs rm -d &> /dev/null || true


FROM clearlinux/os-core:latest

COPY --from=builder /install_root /

ARG R_VERSION
ARG BUILD_DATE
ARG CRAN
ENV BUILD_DATE ${BUILD_DATE:-2021-04-24}
ENV R_VERSION=${R_VERSION:-4.0.3} \
    CRAN=${CRAN:-https://packagemanager.rstudio.com/all/2097505} \ 
    # source packages available as of Apr 1, 2021 1:00 AM GMT+1
    LC_ALL=en_US.UTF-8 \
    LANG=en_US.UTF-8 \
    TERM=xterm


## Add a library directory (for user-installed packages)
# RUN  mkdir -p /usr/lib64/R/site-library \
#   && chown root /usr/lib64/R/site-library \
#   && chmod g+ws /usr/lib64/R/site-library \
#   ## Fix library path
#   && sed -i '/^R_LIBS_USER=.*$/d' /usr/lib64/R/etc/Renviron \
#   && echo "R_LIBS_USER=\${R_LIBS_USER-'/usr/lib64/R/site-library'}" >> /usr/lib64/R/etc/Renviron \
#   && echo "R_LIBS=\${R_LIBS-'/usr/lib64/R/site-library:/usr/lib64/R/library:/usr/lib64/R/library'}" >> /usr/lib64/R/etc/Renviron
#   ## Use littler installation scripts

# Run rm /usr/bin/r

RUN Rscript -e "install.packages(c('gamlss'), repo = '$CRAN', Ncpus = 15)" 


# RUN install2.r -s -r $CRAN -n 15 -e -l /usr/lib64/R/site-library \
#   'data.table', 'fst', 'qs', 'future', 'future.apply', 'foreach', 'gamlss', 'yaml', 'dqrng', 'MASS', 'remotes', 'BH', 'Rcpp'\
#   bsplus colourpicker dichromat doFuture doParallel doRNG  DT  \
#   ggplot2 htmltools iterators  \
#   plotly promises  remotes rngtools shiny shinyBS shinydashboard shinyjs \
#   shinythemes shinyWidgets viridis viridisLite wrswoR \
#   mvtnorm mc2d cowplot 'shiny', 

# RUN installGithub.r "ChristK/CKutils"

CMD ["R"]
