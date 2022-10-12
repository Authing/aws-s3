FROM node:14 as BUILD_IMAGE
WORKDIR /app
COPY package.json ./
COPY yarn.lock ./
RUN yarn config set registry https://registry.npmmirror.com && yarn

FROM node:14
WORKDIR /app
COPY --from=BUILD_IMAGE /app/node_modules ./node_modules
COPY index.html ./
COPY index.js ./
EXPOSE 8888
CMD [ "node", "index.js" ]
