# Qumge MCP

[English](README.md) | [简体中文](README.zh-CN.md)

**两个 Qumge skill 共用的托管平台工具。** Agent 通过 https://qumge.com/mcp 发现和调用交付完整结果的能力，读取 skill 目录与模型信息，并注册或管理开发者的能力。

本仓库提供接入文档与注册元数据。服务器运行在 qumge.com；添加连接不会安装本地运行环境、读取开发者文件或部署应用。

- 服务地址：`https://qumge.com/mcp`
- 传输方式：Streamable HTTP，无状态 POST
- 注册标识：`com.qumge/skills`（保留现有客户端兼容性）

## Skill 与 MCP 的职责

| 入口 | 适用人群 | 职责 |
|---|---|---|
| **qumge** | 能力买家与模型用户 | 查找和使用 Cap、安装目录中的 skill、接入模型客户端、查询消费余额。 |
| **qumge-publish** | 开发者 | 使用编程 Agent 的本地工具分析、适配、测试和部署项目，再通过 MCP 注册、验证、发布和管理 Cap。 |
| **Qumge MCP** | 两者共用 | 操作托管平台；同一地址和账户适用于两个 skill。 |

两个 skill 都在 [Qumge/qumge-skill](https://github.com/Qumge/qumge-skill/blob/main/README.zh-CN.md)。原有使用者安装方式不变：

```bash
npx skills add Qumge/qumge-skill
```

独立安装开发者 skill：

```bash
npx skills add Qumge/qumge-skill --full-depth --skill qumge-publish
```

`--full-depth` 避免根目录 SKILL.md 遮住嵌套 skill。开发者入口自带离线预检与 HTTP/认证参考，无需安装使用者入口；没有第二个 MCP 服务，也不会自动云端托管任意 CLI。

Skill 的说明、提问和面向用户的报告跟随用户语言。工具名、命令、JSON 字段及协议值保持原样；机器错误信息可能仍使用英文，由 Agent 解释。

## 连接

搜索无需密钥。消耗余额的操作需要密钥（`sk_qumge_…`，从 https://qumge.com/en/gateway/api_keys 获取）；也可以暂不提供，在首次需要时由 Agent 打开登录链接供你确认。

**Claude Code**

```bash
claude mcp add --transport http qumge https://qumge.com/mcp
# 携带密钥：
claude mcp add --transport http qumge https://qumge.com/mcp \
  --header "Authorization: Bearer sk_qumge_…"
```

**Cursor** — `~/.cursor/mcp.json`

```json
{
  "mcpServers": {
    "qumge": {
      "url": "https://qumge.com/mcp",
      "headers": { "Authorization": "Bearer sk_qumge_…" }
    }
  }
}
```

**VS Code** — `.vscode/mcp.json`

```json
{
  "servers": {
    "qumge": {
      "type": "http",
      "url": "https://qumge.com/mcp",
      "headers": { "Authorization": "Bearer sk_qumge_…" }
    }
  }
}
```

**Claude.ai / Claude Desktop / ChatGPT 连接器**：添加自定义连接器，地址为 `https://qumge.com/mcp`。这些客户端不能设置请求头，付费工具首次通过 OAuth 登录；创建的密钥会在 API Keys 中显示为“<client> via OAuth”。

**不能设置请求头或使用 OAuth 的客户端**：在付费工具参数中传入 `qumge_key: "sk_qumge_…"`。

## 工具

每个工具通过 `tools/list` 提供当前输入和输出 schema。优先读取 `structuredContent` JSON；`content` 文本用于展示。同时处理协议错误与 `result.isError`。完整参考：https://qumge.com/en/docs/mcp。

| 工具 | 密钥 | 用途 |
|---|---|---|
| `search_caps` | 无需 | 按任务与公开价格查找交付完整结果的能力 |
| `get_cap` | 可选 | 读取生效或待生效合同、操作、限制和确认要求 |
| `call_cap` | 需要 | 调用操作；按要求使用稳定幂等键与已接受合同摘要 |
| `get_cap_job` | 需要 | 免费读取缓存任务进度、结果与回执；支持时显式使用 refresh_result 更新链接 |
| `get_balance` | 需要 | 消费余额、月度限制与充值链接 |
| `search_skills` | 无需 | 搜索精选 skill 目录 |
| `get_skill` | 无需 | 获取供 Agent 安装的 SKILL.md 及可选配套文件 |
| `list_categories` | 无需 | skill 分类与数量 |
| `list_models` | 无需 | 发现可用且支持工具调用的模型；推理走兼容模型 API |
| `list_wanted` | 无需 | 公开的能力需求证据 |
| `become_developer` | 需要 | 开通所有者的开发者账户 |
| `list_caps` | 需要 | 查看所有者的能力状态 |
| `verify_domain` | 需要 | 验证服务域名，作为释放冻结开发者收益的条件 |
| `publish_cap` | 需要 | 从已部署 manifest 创建或更新草稿；不负责部署，也不直接上线 |
| `test_cap` | 需要 | 验证适用的连接或 fixture 合同；需要时指定候选 price_version |
| `submit_cap` | 需要 | 在所有者发布授权范围内上线已测试草稿 |
| `cap_status` | 需要 | 读取发布检查项与生效、待生效状态 |
| `migrate_cap_contract` | 需要 | 所有者范围内迁移合同：prepare/test/activate/status/repair_review；读取当前 schema 后使用 |
| `delist_cap` | 需要 | 立即停止新调用，保留标记为下架的公开页面 |
| `relist_cap` | 需要 | 恢复已下架 Cap；地址变更后重新测试 |
| `get_earnings` | 需要 | 开发者待结算、可支付及已支付收益 |
| `request_payout` | 需要 | 在所有者授权范围内申请提取 Cap 收入 |

旧客户端的重命名前别名仍可分派，包括 search_apps/get_app/call_app、publish_app/test_app/submit_app_review/app_status/list_apps。新客户端使用 Cap 名称。

## 当前默认发布方式

使用托管 **manifest v2**，描述一种明确输入和一个完整可用结果：
https://qumge.com/schemas/qumge-manifest/v2.json。

提供方凭据保存在私有命名连接中，不能放进公开 JSON。通过 HTTPS 提供真实 manifest，再调用 `publish_cap(manifest_url:, slug:)`。manifest 中的建议价格不等于所有者已授权。

开发者 Agent 使用项目已有框架、任务、worker 和私有存储，只实现并部署缺少的接口。Qumge 提供发现、调用、买方订单与结算；业务执行环境由提供方负责。

先做本地检查，再运行 `test_cap`；区分连接检查、fixture 和 `real_delivery`，读取实际测试版本。fixture 不证明业务质量或真实付费交付。仅在已有发布授权范围内调用 `submit_cap`，不重复索要已给出的授权。若缺少定价或发布范围，先准备可审阅草稿，只询问缺失决定。随后读回实际上线、生效状态。

域名验证用于释放收益，不是单纯上架的前提。已被其他开发者验证的域名不能重复认领。密钥、真实付费测试、部署和发布分别对应不同授权范围。

### 已有 API 或远程 MCP

能交付完整结果的 API/MCP 操作可复用，并使用受支持的托管执行映射。多个局部操作需在提供方服务器内部编排。CLI 或内部函数需增加轻量 HTTPS 接口，并选择真实部署环境。

高级旧版手动 HTTP 价目表及 mcp_url/mcp_tools 注册仍兼容。新托管接入应读取 `tools/list` 与现行文档，避免照搬旧 v1 示例。原生 MCP 的 isError/JSON-RPC 工具错误不算成功计费结果。托管结算要求完整成功结果与输出 schema，不能仅凭 2xx 或 accepted/queued 任务 ID 结算。

## 调用与付费

买家依据当前 `get_cap` 的交付内容、价格及消费授权调用。如果 `contract_state.confirmation_required` 为 true，先确认变更后的结果，再将当前 `contract_digest` 作为 `accepted_contract_digest` 传入。旧授权不代表接受不同交付内容。

重试同一托管操作和输入时，复用同一个 `idempotency_key`；轮询返回的平台任务 ID，避免创建重复生成。

Qumge 按量付费：先充值，再按完整托管结果或模型用量扣费。部分 Cap 为曾充值用户提供免费调用次数，成功调用会消耗一次。可用性、价格和免费次数以当前目录和合同为准；不承诺试用赠金或比直连提供方更低的价格。402 表示余额或月度限制问题，先解决原因再继续。

## 常见问题

**只装 MCP 就能分析并部署本地项目吗？** MCP 操作平台；本地代码检查、适配和部署由编程 Agent 配合 qumge-publish 完成。

**需要两套账户或密钥吗？** 不需要，两个 skill 共用同一平台账户与 MCP 地址。

**草稿创建成功就是上线了吗？** 不是。还需要相应测试和发布授权，并通过 `cap_status` 读回实际状态。

**会为中文另开一个 MCP 吗？** 不会。中文文档和 Agent 交流共用现有工具与协议。

## 参考资料

- Skills：https://github.com/Qumge/qumge-skill
- 当前托管合同：https://qumge.com/en/docs/caps/managed
- Manifest：https://qumge.com/en/docs/caps/manifest
- Agent 索引：https://qumge.com/llms.txt
- OpenAPI 目录：https://qumge.com/v1/caps/openapi.json

## 许可

文档使用 MIT 许可。托管服务适用 qumge.com 的服务条款。
