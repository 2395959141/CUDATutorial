# 定义变量
BUILD_DIR = build
DIST_DIR = dist

# 默认目标改为直接构建
.PHONY: all
all:
	@echo "可用的目标："
	@echo "  build  - 构建项目（Release模式）"
	@echo "  clean  - 清理项目"

# 构建目标（优化后的Release模式构建）
.PHONY: build
build:
	@echo "开始构建项目（Release模式）..."
	mkdir -p $(BUILD_DIR) $(DIST_DIR)
	cd $(BUILD_DIR) && cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_CUDA_COMPILER=/usr/local/cuda-12.6/bin/nvcc .. && make -j$(nproc)
	@echo "构建完成，可执行文件位于 $(BUILD_DIR)/bin"

# 新增安装目标
.PHONY: install
install:
	@echo "正在安装到 $(DIST_DIR)..."
	cp -r $(BUILD_DIR)/bin $(DIST_DIR)/
	@echo "安装完成"

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