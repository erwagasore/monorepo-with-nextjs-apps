FROM node:18-alpine AS base
RUN apk update && apk add --no-cache libc6-compat
RUN npm i -g turbo
RUN npm i -g pnpm

FROM base AS pruner
WORKDIR /app
COPY . .
RUN pnpm turbo prune --scope=web --docker

FROM base AS deps
WORKDIR /app

COPY .gitignore .gitignore
COPY --from=pruner /app/out/json/ .
COPY --from=pruner /app/out/pnpm-lock.yaml ./pnpm-lock.yaml
RUN pnpm fetch

COPY --from=pruner /app/out/full/ .
RUN pnpm install -r --offline --ignore-scripts

EXPOSE 3000
CMD  ["pnpm" "dev"]
