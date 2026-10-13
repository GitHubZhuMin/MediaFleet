# MediaFleet 智能体协作说明

## 项目边界

MediaFleet 是由多个可独立部署服务组成的分布式媒体控制与处理平台。

- MySQL 是节点、绑定、任务、投递状态和媒体产物的事实来源。
- RabbitMQ 提供至少一次投递。生产者和消费者必须支持幂等，并使用发布确认、手动 ACK、
  有限重试和死信队列。
- 录制命令必须路由到拥有对应 ZLMediaKit 实例和录像文件的录制节点。
- 通用媒体任务由共享持久队列上的 Worker 竞争消费。
- 离线 ASR 模型加载和推理必须保留在 `media-worker` 内。
- 控制平面不能运行 FFmpeg、读取录制节点本地目录或加载媒体/AI 模型。
- 内存状态和 Redis 可以优化运行效率，但不能成为分布式正确性的唯一来源。

## 修改代码前

1. 执行 `git status --short --branch` 并保留已有工作。
2. 阅读 `docs/architecture/overview.md`。
3. 阅读 `docs/project-status.md`，从第一个未完成事项继续。
4. 修改消息或 API 契约前，检查每一个生产者和消费者。
5. 尽可能让一次变更保持在一个清晰的服务边界内。

## 安全与开源卫生

- 不得提交 `.env`、凭据、令牌、私钥、签名 URL、带凭据的 RTSP URL 或内网地址。
- 日志必须脱敏 URL 用户信息和敏感查询参数。
- 没有可再分发许可证说明时，不得添加二进制模型权重或字体。
- 配置示例只能使用空值或明确的占位符。
- 运行时配置 API 必须类型化并使用允许列表；不得暴露任意环境变量修改端点。

## 接口

REST、CLI、MCP 和运维控制台必须调用相同应用服务。CLI 和 MCP 适配器通常应通过共享
SDK 访问控制平面 API，不能通过直接访问数据库或 RabbitMQ 绕过授权。

## 完成要求

运行与变更风险相称的测试和静态检查。更新 `docs/project-status.md`，写明完成范围、验证、
剩余风险和一个明确的下一步。持久架构决策发生变化时同步更新架构文档。

## Cursor Cloud 开发环境

Cloud Agent 每次启动会拉起本机 MySQL、RabbitMQ 和调用中心。调用中心监听
`0.0.0.0:8008`，健康检查是 `http://127.0.0.1:8008/health`，接口文档是 `/api/docs`，
运维控制台是 `/admin/`。

本地开发使用仓库示例中的公开占位符 `change-me`：

- MySQL：`127.0.0.1:3306`，用户 `mediafleet`，数据库 `mediafleet`
- RabbitMQ：`127.0.0.1:5672`，用户 `guest`，节点名固定为 `rabbit@localhost`
- 调用中心请求头 `X-API-Key: change-me`

自动启动的调用中心设置了 `IGNORE_ENV_FILE=true` 和 `SERVICE_DOTENV_ENABLED=false`，
不会读取仓库里的 `.env`。改完调用中心代码后，重启 tmux 会话
`mediafleet-control-center`。

依赖与 CI 一致，使用 uv `0.12.20` 和 `uv sync --frozen`。系统已提供 Python 3.12 和
FFmpeg。`media-worker` 的 Torch、FunASR 等可选依赖默认不安装；处理离线 ASR 或目标检测时
再执行 `uv sync --frozen --extra media-worker`。图像分析接单保持关闭。本环境不安装
Docker，Compose 校验需要单独准备 Docker。
