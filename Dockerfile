# Build Stage (as 써서 빌드 단계라는 걸 나타내줌)
FROM node:alpine as builder

WORKDIR /usr/src/app

COPY package.json ./

RUN npm install

COPY ./ ./

# 생성된 파일과 폴더들은 /usr/src/app/build 컨테이너 경로로 들어감.
CMD ["npm", "run", "build"] 


# Run Stage
FROM nginx

COPY --from=builder /usr/src/app/build /usr/share/nginx/html