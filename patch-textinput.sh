#!/bin/bash
set -e

TARGET_FILE="joplin/packages/app-mobile/components/TextInput.tsx"

if [ ! -f "$TARGET_FILE" ]; then
  echo "❌ 找不到 TextInput.tsx，跳过补丁"
  exit 0
fi

# 删除最后一行（原始 TextInput 渲染）
sed -i '$d' "$TARGET_FILE"

# 插入干净的 TextInput 渲染逻辑（无事件监听）
cat <<EOF >> "$TARGET_FILE"
  return (
    <TextInput
      {...finalProps}
    />
  );
};
EOF

echo "✅ TextInput.tsx 已清理为纯输入框，无事件监听，适配 Web 中文输入"
