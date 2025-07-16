# 变量定义
APP_NAME := myserver
DOCKER_IMAGE := $(APP_NAME)
DOCKER_TAG := latest
PORT := 8080
GITHUB_REGISTRY := ghcr.io
GITHUB_USER := your-username
GITHUB_IMAGE := $(GITHUB_REGISTRY)/$(GITHUB_USER)/$(APP_NAME)

# 默认目标
.PHONY: help
help:
	@echo "可用的命令:"
	@echo "  build        - 构建Docker镜像"
	@echo "  run          - 运行Docker容器"
	@echo "  stop         - 停止Docker容器"
	@echo "  clean        - 清理Docker镜像和容器"
	@echo "  test         - 测试应用"
	@echo "  dev          - 本地开发模式运行"
	@echo "  deps         - 安装Go依赖"
	@echo "  push         - 推送镜像到GitHub Registry"
	@echo "  pull         - 从GitHub Registry拉取镜像"
	@echo "  deploy       - 部署GitHub Registry镜像"

# 安装Go依赖
.PHONY: deps
deps:
	go mod tidy
	go mod download

# 本地开发运行
.PHONY: dev
dev: deps
	go run main.go

# 测试应用
.PHONY: test
test:
	go test -v ./...

# 构建Docker镜像
.PHONY: build
build:
	@echo "构建Docker镜像: $(DOCKER_IMAGE):$(DOCKER_TAG)"
	docker build -t $(DOCKER_IMAGE):$(DOCKER_TAG) .
	@echo "镜像构建完成!"

# 运行Docker容器
.PHONY: run
run:
	@echo "启动Docker容器..."
	docker run -d --name $(APP_NAME) -p $(PORT):$(PORT) $(DOCKER_IMAGE):$(DOCKER_TAG)
	@echo "容器已启动，访问地址: http://localhost:$(PORT)"

# 停止并删除容器
.PHONY: stop
stop:
	@echo "停止Docker容器..."
	-docker stop $(APP_NAME)
	-docker rm $(APP_NAME)
	@echo "容器已停止"

# 清理Docker镜像和容器
.PHONY: clean
clean: stop
	@echo "清理Docker镜像..."
	-docker rmi $(DOCKER_IMAGE):$(DOCKER_TAG)
	-docker rmi $(GITHUB_IMAGE):$(DOCKER_TAG)
	@echo "清理完成"

# 标记镜像用于推送到GitHub Registry
.PHONY: tag
tag:
	@echo "标记镜像用于GitHub Registry..."
	docker tag $(DOCKER_IMAGE):$(DOCKER_TAG) $(GITHUB_IMAGE):$(DOCKER_TAG)

# 推送镜像到GitHub Registry
.PHONY: push
push: build tag
	@echo "推送镜像到GitHub Registry..."
	docker push $(GITHUB_IMAGE):$(DOCKER_TAG)
	@echo "镜像推送完成!"

# 从GitHub Registry拉取镜像
.PHONY: pull
pull:
	@echo "从GitHub Registry拉取镜像..."
	docker pull $(GITHUB_IMAGE):$(DOCKER_TAG)

# 部署GitHub Registry镜像
.PHONY: deploy
deploy: pull
	@echo "部署GitHub Registry镜像..."
	-docker stop $(APP_NAME)
	-docker rm $(APP_NAME)
	docker run -d --name $(APP_NAME) -p $(PORT):$(PORT) $(GITHUB_IMAGE):$(DOCKER_TAG)
	@echo "部署完成，访问地址: http://localhost:$(PORT)"

# 重启容器
.PHONY: restart
restart: stop run

# 查看容器日志
.PHONY: logs
logs:
	docker logs -f $(APP_NAME)

# 进入容器shell
.PHONY: shell
shell:
	docker exec -it $(APP_NAME) /bin/sh

# 健康检查
.PHONY: health
health:
	@echo "检查应用健康状态..."
	@curl -f http://localhost:$(PORT)/health || echo "应用未响应"

# 完整的构建和运行流程
.PHONY: up
up: build run
	@echo "应用已启动完成!"

# 完整的停止和清理流程
.PHONY: down
down: stop clean
	@echo "应用已完全停止和清理!"