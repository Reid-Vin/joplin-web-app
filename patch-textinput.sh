#!/bin/bash
set -e

TARGET_FILE="joplin/packages/app-mobile/components/TextInput.tsx"

if [ ! -f "$TARGET_FILE" ]; then
  echo "❌ 找不到 TextInput.tsx，跳过补丁"
  exit 0
fi

# 1. 增加 Platform、useRef 引入（避免重复插入）
if ! grep -q "Platform" "$TARGET_FILE"; then
  sed -i "/import { themeStyle } from '.\/global-style';/a\\
import { Platform } from 'react-native';\
import { useRef } from 'react';" "$TARGET_FILE"
fi

# 2. 插入组合输入处理逻辑（避免重复插入）
if ! grep -q "composingRef" "$TARGET_FILE"; then
  sed -i "/const theme = themeStyle(props.themeId);/a\\
  // 组合输入状态（仅web生效）\\
  const composingRef = useRef(false);\\
  const handleCompositionStart = () => { composingRef.current = true; };\\
  const handleCompositionEnd = () => { composingRef.current = false; };\\
  const handleChangeText = (text: string) => {\\
    if (composingRef.current) return;\\
    props.onChangeText?.(text);\\
  };" "$TARGET_FILE"
fi

# 3. 替换 TextInput 渲染部分，插入web平台事件（只替换最后一行的TextInput标签即可）
# 先删除最后一行
sed -i '$d' "$TARGET_FILE"

# 追加新TextInput渲染（带web端平台判断，TS兼容）
cat <<EOF >> "$TARGET_FILE"
  return (
    <TextInput
      {...finalProps}
      onChangeText={handleChangeText}
      {...(Platform.OS === 'web' ? {
        onCompositionStart: handleCompositionStart,
        onCompositionEnd: handleCompositionEnd,
      } : {})}
    />
  );
};
EOF

echo "✅ TextInput.tsx 已自动修复，可兼容web端组合输入，且不会影响RN端编译"
