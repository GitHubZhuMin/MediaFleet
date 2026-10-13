# Cursor Cloud Agent 开发环境

仓库通过 `.cursor/environment.json` 把 Cloud Agent 环境交给所有协作者。Cursor 解析顺序是：仓库内的该文件、个人已保存环境、团队已保存环境。文件存在时以仓库配置为准。

## 机器里有什么

`.cursor/Dockerfile` 基于 Ubuntu 24.04，安装 Git、编译工具、FFmpeg（含 ffprobe）和与 CI 相同的 uv `0.12.20`。镜像不复制项目源码，提交由 Cursor 检出。

Build 阶段执行 `.cursor/install.sh`，并且可以在已有磁盘上重复执行：

1. 安装 Python 3.12。
2. 执行 `uv sync --frozen --extra image-analysis`，包含开发依赖和当前课堂图像分析客户端。
3. 确认 FastAPI、pytest、OpenAI 客户端和图像分析入口可以导入。

默认不安装 `media-worker` 可选依赖。该额外包含 Torch，体积大，只在修改离线 ASR 或对象检测时另行执行：

```bash
uv sync --frozen --extra media-worker
```

## 不会自动启动的部分

Build 只保留磁盘上的工具和虚拟环境。MySQL、RabbitMQ、对象存储、ZLMediaKit 和五个业务进程都不在 `start` 或 `terminals` 中启动。全量单元测试不依赖这些服务：

```bash
uv run python -m pytest -q
uv run ruff check media_platform services tests
uv run python -m compileall media_platform services alembic
```

`environment.json` 声明了五个服务端口，便于以后手动启动时转发：

| 服务 | 端口 |
| --- | ---: |
| `control-center` | 8008 |
| `media-worker` | 8009 |
| `recorder-node` | 8010 |
| `content-analysis` | 8012 |
| `image-analysis` | 8013 |

图像分析接单和消费保持关闭：`IMAGE_ANALYSIS_INTAKE_ENABLED=false`，`IMAGE_ANALYSIS_CONSUMER_ENABLED=false`。

## 密钥

单元测试和静态检查不需要真实凭据。数据库、消息队列、对象存储和模型密钥放在 Cursor 的 Secrets 中，不写入仓库、快照说明或日志。配置示例继续使用 `.env.example` 里的空值或占位符。

如果团队网络策略收紧为仅允许名单，安装阶段需要能访问 `pypi.org`、`files.pythonhosted.org`、`astral.sh` 和 `github.com`。

## 让 Cloud Agent 使用这份环境

1. 把包含 `.cursor/environment.json` 的提交推到 GitHub。Cloud Agent 使用它启动时所在提交里的配置；默认分支上的 Build 会预先准备依赖。
2. 在 Cursor 的 Cloud Agents 面板连接 `huxiaodong1989/MediaFleet` 所在的 GitHub 账号。
3. 从该仓库启动 Agent，或打开环境的 Builds 页面确认首次 Build 成功。
4. 失败的 Build 不会替换上一次成功的环境。查看 Build 日志后修正安装脚本再推送。

自托管 Cloud Agent 机器不读取 `.cursor/environment.json`，需要在机器镜像或会话启动钩子里自行安装同等依赖。
