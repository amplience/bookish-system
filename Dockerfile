FROM node:19-alpine

COPY src/index.js /index.js

EXPOSE 8000

CMD node /index.js