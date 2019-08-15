# Example custom Keycloak image
This is an example of a child image packaging project specific files (a theme)

## Local theme development guide
This setup can be used to develop and test a Keycloak theme locally.

1. Run `docker-compose up` to start DB and Keycloak. This symlinks the files in
   the `toRoot/themes` folder with the themes folder inside the Keycloak
   container
2. Log into the administration interface and set the login theme for the master
   realm to "exampletheme".
3. Access the login screen at
   [localhost:8080/auth/admin](http://localhost:8080/auth/admin)
4. Start editing files in `toRoot/themes`. Reload the browser to see the updated
   changes (you likely want to have DevTools open to stop content from caching)