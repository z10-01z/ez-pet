# EZ娘 · Windows 桌面伙伴

给队友使用的 EZ 赛车主题伙伴，包含九种动作与十六向注视。保留渐变长发、异色瞳、青色目镜、碳纤维翼片和直柄镰刀。

![九种动作预览](previews/actions.gif)
![十六向注视预览](previews/look.gif)

## 下载

1. 登录已获邀访问本仓库的 GitHub 账号。
2. 打开 [最新发布](https://github.com/z10-01z/ez-pet/releases/latest)，下载 `EZ-Pet-v1.0.0-Windows.zip`。
3. 先完整解压 ZIP，再按下方任一种方式安装。

这是私有仓库；未接受仓库邀请的账号无法下载。不要把整个 ZIP 直接拖进伙伴列表。

## 手动安装

1. 按 `Win + R`，输入 `%USERPROFILE%\.codex\pets`，按回车。目录不存在时先创建它。
2. 把解压包中的整个 `ez-girl` 文件夹复制到这里。最终应有：

   ```text
   .codex/
     pets/
       ez-girl/
         pet.json
         spritesheet.png
   ```

3. 打开桌面应用的「设置 → 迷你界面和智能伙伴」（部分版本称「Pets」），点击「我的智能伙伴」右侧的 **↻ 刷新**，选择 **EZ娘**。

如果设置过 `CODEX_HOME` 环境变量，请安装到该目录下的 `pets\ez-girl`。需要更新时，优先使用下方脚本，它会自动保留旧文件。

## 脚本安装或更新

在解压后的文件夹打开 PowerShell，执行：

```powershell
powershell.exe -NoProfile -File .\install.ps1
```

如果系统的脚本策略阻止执行，可以使用上方手动安装方法。

脚本支持 Windows PowerShell 5.1，无需管理员权限，也无需安装 Python、Node.js 或其他依赖。它会：

- 优先使用 `$env:CODEX_HOME\pets`；没有设置时使用 `%USERPROFILE%\.codex\pets`。
- 始终安装到同一个 `ez-girl` 文件夹，重复安装会原位更新。
- 更新前，将整个旧 `ez-girl` 备份到同级 `pet-backups\ez-girl\时间戳` 下，备份不会出现在伙伴列表中。
- 检查精灵图 SHA-256，完成后提示刷新列表。

自定义安装根目录：

```powershell
powershell.exe -NoProfile -File .\install.ps1 -Destination 'D:\MyCodex\pets'
```

`-Destination` 指向 **pets 根目录**，脚本会自行追加 `ez-girl`。

## 更新与恢复

更新时下载并解压新版，再执行 `install.ps1`。保留文件夹名 `ez-girl`，避免出现同名伙伴的多个条目。

如需恢复旧版，把备份中的 `ez-girl` 内容复制回安装目录，再刷新列表。手动更新前，也可以自行将旧文件夹备份到 `pets` 目录之外。

## 文件校验

发布页同时提供 `SHA256SUMS.txt`，其中记录 ZIP 的 SHA-256。下载后可检查：

```powershell
Get-FileHash -LiteralPath .\EZ-Pet-v1.0.0-Windows.zip -Algorithm SHA256
```

最终精灵图：透明 PNG，1536 × 2288，v2，73 个有效帧；SHA-256：

```text
6add1e1e4927afc4e95cbdf5060fe3d90aafed953cf2844a0ac61dfa03801167
```

## 客户端与常见问题

- 需要 Windows 桌面版 ChatGPT/Codex，并支持自定义 v2 伙伴。已用 26.1103.3517.0 的图片读取逻辑验证格式。
- 安装后找不到：确认文件夹层级正确、`pet.json` 与 PNG 在一起，再点击刷新。
- 出现多个 EZ娘：检查是否复制成了 `ez-girl-2`、`ez-girl (1)` 等多个直接子文件夹。保留固定目录，备份放到 `pets` 之外。
- 动画不播放：检查操作系统是否开启了减少动画/减少动态效果。
- 此安装包安装本机伙伴文件，不操作云端 Pets 接口，不会替换当前选中的伙伴。

## 给队友开放访问

仓库所有者在 GitHub 打开 **Settings → Collaborators → Add people**，输入队友的 GitHub 用户名并发送邀请。队友接受邀请后，再登录并下载 Release 安装包。

## 内容说明

本包基于 EZ娘最终设定制作，角色图像与动画使用 AI 图像生成工具完成，经动作、方向和图集检查后整理分发。用于车队内部交流，仓库保持私有。
