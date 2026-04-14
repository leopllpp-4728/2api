FROM node:20-alpine
WORKDIR /app
COPY *.mjs package.json ./
EXPOSE 3000
ENV NODE_ENV=production
CMD ["node", "index.mjs"]
