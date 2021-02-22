FROM alpine:3.13

WORKDIR /app
COPY . .

RUN mkdir -p /app/static

RUN apk add npm
RUN npm install
CMD [ "npx", "webpack", "-p", "--color", "--progress" ]
