#!/bin/bash
set -e

TARGET_FILE="joplin/packages/app-mobile/components/TextInput.tsx"

# 检查文件是否存在
if [ ! -f "$TARGET_FILE" ]; then
  echo "❌ 找不到 TextInput.tsx，跳过补丁"
  exit 0
fi

# 插入组合事件处理逻辑（只在第一次构建时插入）
if ! grep -q "onCompositionStart" "$TARGET_FILE"; then
  echo "✅ 注入组合事件处理逻辑到 TextInput.tsx"

  # 在 import 后插入 useRef
  sed -i "/import { TextInputProps } from 'react-native';/a\\
import { useRef } from 'react';
" "$TARGET_FILE"

  # 在组件函数内部插入组合状态逻辑
  sed -i "/const TextInputComponent =/a\\
  const composingRef = useRef(false);\\
  const handleCompositionStart = () => { composingRef.current = true; };\\
  const handleCompositionEnd = () => { composingRef.current = false; };\\
  const handleChangeText = (text: string) => {\\
    if (composingRef.current) return;\\
    props.onChangeText?.(text);\\
  };
" "$TARGET_FILE"

  # 替换原来的 onChangeText 为 handleChangeText，并添加组合事件
  sed -i "s/<TextInput /<TextInput onChangeText={handleChangeText} onCompositionStart={handleCompositionStart} onCompositionEnd={handleCompositionEnd} /" "$TARGET_FILE"
else
  echo "⚠️ TextInput.tsx 已包含组合事件处理逻辑，跳过注入"
fi
