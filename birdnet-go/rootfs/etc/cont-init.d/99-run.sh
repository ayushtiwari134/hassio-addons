#!/command/with-contenv bashio
# shellcheck shell=bash
set -e

#################
# INITALISATION #
#################

bashio::log.info "ALSA_CARD option is set to $(bashio::config "ALSA_CARD"). If the microphone doesn't work, please adapt it"
echo " "

########################
# CONFIGURE birdnet-go #
########################

bashio::log.info "Starting app..."
/usr/bin/birdnet-go realtime & true

# Wait for app to become available to start nginx
bashio::net.wait_for 8096 localhost 900
bashio::log.info "Starting NGinx..."
exec nginx
