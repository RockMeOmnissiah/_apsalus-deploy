FROM node:alpine

RUN apk add nodejs
# install dependencies
RUN npm install -g npm
RUN npm install -g sails
RUN npm install -g pm2
# RUN npm install -g grunt-cli
