FROM capraconsulting/keycloak-docker:latest

COPY toRoot/ $HOME/

USER root
RUN mv -f $HOME/themes/* $HOME/keycloak/themes/ \
    chown -R $USER $HOME

USER $USER
WORKDIR /home/$USER
CMD ["./runapp.sh"]