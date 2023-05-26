FROM node:alpine AS base
RUN apk add --no-cache libc6-compat
RUN apk update
RUN yarn global add turbo
RUN yarn global add pnpm

FROM base AS builder
WORKDIR /app
COPY . .
RUN turbo prune --scope=web --docker

FROM base AS installer
WORKDIR /app
COPY .gitignore .gitignore
COPY --from=builder /app/out/json/ .
COPY --from=builder /app/out/pnpm-lock.yaml ./pnpm-lock.yaml
RUN pnpm fetch

# Build the project
COPY --from=builder /app/out/full/ .
RUN pnpm install -r --offline --ignore-scripts
RUN pnpm build --filter=web

# nginx state for serving content
FROM nginx:alpine as RUNNER
WORKDIR /usr/share/nginx/html
RUN addgroup --system --gid 1001 static
RUN adduser --system --uid 1001 ngnix

RUN rm -rf ./*
# Copy static assets over
COPY --from=installer --chown=static:ngnix /app/apps/web/out ./
USER ngnix
# Containers run nginx with global directives and daemon off
ENTRYPOINT ["nginx", "-g", "daemon off;"]
