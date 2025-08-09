# ---------- Build stage ----------
FROM node:18-bullseye AS build
WORKDIR /app
ENV NODE_ENV=production

# Copy lockfiles if present (supports yarn/npm/pnpm)
COPY package.json yarn.lock* package-lock.json* pnpm-lock.yaml* ./
RUN \
  if [ -f yarn.lock ]; then yarn install --frozen-lockfile; \
  elif [ -f package-lock.json ]; then npm ci; \
  elif [ -f pnpm-lock.yaml ]; then npm i -g pnpm && pnpm i --frozen-lockfile; \
  else npm i; fi

# Copy source and build Strapi admin
COPY . .
RUN npm run build || yarn build

# ---------- Run stage ----------
FROM node:18-bullseye
WORKDIR /app
ENV NODE_ENV=production
ENV PORT=8080
EXPOSE 8080

# Copy built app
COPY --from=build /app ./

# Start Strapi
CMD ["npm","run","start"]
