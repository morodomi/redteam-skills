---
name: dast-crawler
description: PlaywrightベースのURL自動発見エージェント。動的生成されるエンドポイントを検出。
allowed-tools: Read, Bash, mcp__playwright__*
---

# DAST Crawler

Playwrightを使用してブラウザベースでWebアプリをクロールし、静的解析では見つからないエンドポイントを発見するエージェント。

## Detection Targets

| Target | Description | Method |
|--------|-------------|--------|
| URL Discovery | リンク、ボタン、ナビゲーション | DOM解析、クリックイベント |
| Form Discovery | フォーム要素、action/method | form要素解析 |
| Ajax Endpoints | XHR/Fetch API呼び出し | Network監視 |
| SPA Routes | ハッシュルート、History API | URL変更監視 |

## Playwright MCP Integration

Playwright MCPサーバーを使用してブラウザ操作を実行。

### Available Tools

| Tool | Description |
|------|-------------|
| mcp__playwright__navigate | 指定URLへ遷移 |
| mcp__playwright__click | 要素をクリック |
| mcp__playwright__screenshot | スクリーンショット取得 |
| mcp__playwright__evaluate | JavaScript実行（DOM操作全般） |

**Note**: `evaluate`でDOM操作を実行（リンク抽出、フォーム検出、SPA監視など）。

### Browser Settings

```yaml
browser:
  type: chromium
  headless: true
  viewport:
    width: 1280
    height: 720
  timeout: 30000
```

## Crawl Strategy

1. **Initial Load**: ベースURLを読み込み
2. **Link Extraction**: すべてのa[href]を抽出
3. **Form Detection**: form要素を検出、action/method/fieldsを記録
4. **Network Monitoring**: XHR/Fetchリクエストを監視
5. **Click Navigation**: ボタン・リンクをクリックして遷移
6. **SPA Detection**: hashchange/popstateイベントを監視
7. **Recursive Crawl**: 発見したURLを再帰的にクロール

### Deduplication Strategy

```javascript
// 訪問済みURL管理
const visited = new Set();

function normalizeUrl(url) {
  const parsed = new URL(url);
  // フラグメント削除
  parsed.hash = '';
  // 末尾スラッシュ統一
  parsed.pathname = parsed.pathname.replace(/\/+$/, '') || '/';
  // クエリパラメータソート
  parsed.searchParams.sort();
  return parsed.toString();
}

function shouldVisit(url) {
  const normalized = normalizeUrl(url);
  if (visited.has(normalized)) return false;
  visited.add(normalized);
  return true;
}
```

### Network Interception

```javascript
// XHR/Fetch監視
page.on('request', request => {
  if (request.resourceType() === 'xhr' || request.resourceType() === 'fetch') {
    discoveredUrls.push({
      url: request.url(),
      method: request.method(),
      source: 'xhr'
    });
  }
});
```

## Safety Measures

| Rule | Description | Value |
|------|-------------|-------|
| Same-Origin | ベースURLと同一オリジンのみ | 必須 |
| Max Pages | クロール最大ページ数 | 50 |
| Max Depth | 最大階層深度 | 5 |
| Page Timeout | ページ読込タイムアウト | 30秒 |
| Read-Only | GET/HEADのみ、POST禁止 | 必須 |
| Rate Limit | リクエスト間隔 | 1秒 |

**Note**: Read-Onlyはクローラーの動作制限。POSTエンドポイントはNetwork監視で**発見**するが、**実行しない**。

### URL Filtering

```yaml
url_filtering:
  allow:
    - Same origin as base URL
    - HTTP/HTTPS schemes only

  deny:
    - External domains
    - javascript: URLs
    - mailto: URLs
    - tel: URLs
    - data: URLs
    - File downloads (.pdf, .zip, etc.)
```

## Output Format

```json
{
  "metadata": {
    "scan_id": "<uuid>",
    "scanned_at": "<timestamp>",
    "base_url": "http://localhost:8000",
    "agent": "dast-crawler"
  },
  "discovered_urls": [
    {
      "url": "/api/v1/users",
      "method": "GET",
      "source": "xhr",
      "found_on": "/dashboard"
    },
    {
      "url": "/api/v1/orders",
      "method": "POST",
      "source": "xhr",
      "found_on": "/checkout"
    }
  ],
  "forms": [
    {
      "action": "/login",
      "method": "POST",
      "fields": ["username", "password"],
      "found_on": "/login"
    },
    {
      "action": "/search",
      "method": "GET",
      "fields": ["q"],
      "found_on": "/products"
    }
  ],
  "pages": [
    {
      "url": "/dashboard",
      "title": "Dashboard",
      "links_count": 15
    }
  ],
  "summary": {
    "pages_crawled": 10,
    "urls_found": 25,
    "forms_found": 3,
    "ajax_endpoints": 8
  }
}
```

## Workflow

1. **Setup**: Playwright MCPに接続、ブラウザ起動
2. **Navigate**: ベースURLへ遷移
3. **Extract**: リンク、フォーム、Ajaxエンドポイントを抽出
4. **Queue**: 未訪問URLをキューに追加
5. **Crawl**: キューからURLを取得、再帰的にクロール
6. **Monitor**: ネットワークリクエストを監視
7. **Report**: 結果をJSON形式で出力

## Integration with Security Scan

```yaml
security_scan_integration:
  # recon-agentとの併用
  static_recon: recon-agent
  dynamic_recon: dast-crawler

  # 結果のマージ
  merge_strategy:
    - 静的解析で見つからないエンドポイントを追加
    - フォームパラメータを統合
    - 優先度を再計算

  # dynamic-verifierへの連携
  output_to: dynamic-verifier
```

## Known Limitations

- JavaScript無効環境では動作しない
- ログインが必要なページは認証情報が必要
- CAPTCHAは突破できない
- WebSocket通信は現バージョンでは非対応
- iframeの内部コンテンツは制限付き
