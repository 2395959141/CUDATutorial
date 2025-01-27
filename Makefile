# 定义变量
BUILD_DIR = build
DIST_DIR = dist

# 默认目标
.PHONY: all
all:
	@echo "可用的目标："
	@echo "  build  - 构建项目"
	@echo "  clean  - 清理项目"

# 构建目标
.PHONY: build
build:
	@echo "开始构建项目..."
	mkdir -p $(BUILD_DIR)
	cd $(BUILD_DIR) && cmake .. && make -j8
	@echo "构建完成"

# 清理目标
.PHONY: clean
clean:
	@echo "正在清理项目..."
	rm -rf $(BUILD_DIR)
	rm -rf $(DIST_DIR)
	find . -type f -name "*.o" -delete
	find . -type f -name "*.exe" -delete
	find . -type f -name "*.out" -delete
	find . -type f -name "*.log" -delete
	@echo "清理完成" 