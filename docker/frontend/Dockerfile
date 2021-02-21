FROM alpine:3.13

WORKDIR /app
COPY . .

RUN mkdir -p /app/static

RUN apk add npm gettext
RUN npm install
RUN npx webpack --color --progress -p
