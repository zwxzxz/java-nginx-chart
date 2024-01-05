#!/bin/bash

# 设置变量
chart_file="deployment-1.3.0.tgz"
release_namespace=""

# 检查 release_namespace 是否为空
if [ -z "$release_namespace" ]; then
  echo "错误: 未设置实例命名空间(release_namespace)变量"
  exit 1
fi

# 检查是否提供了参数
if [ $# -ne 1 ]; then
  echo "用法: $0 <配置文件路径>"
  exit 1
fi

# 获取配置文件路径参数
config_file="$1"

# 提取文件名（不包括路径和扩展名）
release_name=$(basename -s .yaml "$config_file")

# 执行 Helm 安装命令
helm install "$release_name" "$chart_file" -n "$release_namespace" -f "$config_file" 
