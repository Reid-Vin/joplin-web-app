FROM nginx:alpine
COPY ./pages/ /usr/share/nginx/html
COPY coop-coep.conf /etc/nginx/conf.d/coop-coep.conf
