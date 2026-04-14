# 部署指南

## 方案一：VPS 直接部署（最简单）

### 1. 准备服务器

任意 Linux VPS（Ubuntu/Debian/CentOS），装好 Node.js 18+：

```bash
# Ubuntu/Debian
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo bash -
sudo apt install -y nodejs

# 验证
node -v  # v20.x
```

### 2. 拉取代码

```bash
git clone https://github.com/leopllpp-4728/2api.git
cd 2api
```

### 3. 配置账号

创建 `.env` 文件：

```bash
cat > .env << 'EOF'
CAPY_EMAIL=你的邮箱
CAPY_PASSWORD=你的密码
CAPY_PROJECT_ID=你的项目ID
PORT=3000
PROXY_API_KEY=自定义一个密钥
EOF
```

或者用 Token 模式：

```bash
cat > .env << 'EOF'
CAPY_API_TOKEN=capy_xxxx
CAPY_PROJECT_ID=你的项目ID
PORT=3000
PROXY_API_KEY=自定义一个密钥
EOF
```

### 4. 启动

```bash
# 前台运行（测试用）
source .env && node index.mjs

# 后台运行（用 PM2）
npm i -g pm2
source .env && pm2 start index.mjs --name 2api
pm2 save
pm2 startup  # 开机自启
```

### 5. 配置反向代理（可选，推荐）

用 Nginx 配域名 + HTTPS：

```bash
sudo apt install -y nginx certbot python3-certbot-nginx
```

```nginx
# /etc/nginx/sites-available/2api
server {
    listen 80;
    server_name api.yourdomain.com;

    location / {
        proxy_pass http://127.0.0.1:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_buffering off;          # SSE 流式必须关闭
        proxy_read_timeout 300s;      # 长请求超时
    }
}
```

```bash
sudo ln -s /etc/nginx/sites-available/2api /etc/nginx/sites-enabled/
sudo nginx -t && sudo systemctl reload nginx
sudo certbot --nginx -d api.yourdomain.com  # 自动HTTPS
```

---

## 方案二：Docker 部署

### 1. 安装 Docker

```bash
curl -fsSL https://get.docker.com | sh
```

### 2. 拉取代码

```bash
git clone https://github.com/leopllpp-4728/2api.git
cd 2api
```

### 3. 配置环境变量

```bash
cat > .env << 'EOF'
CAPY_EMAIL=你的邮箱
CAPY_PASSWORD=你的密码
CAPY_PROJECT_ID=你的项目ID
PROXY_API_KEY=自定义一个密钥
STREAM_MODE=auto
DEFAULT_MODEL=auto
EOF
```

### 4. 启动

```bash
docker compose up -d
```

### 常用命令

```bash
docker compose logs -f      # 查看日志
docker compose restart       # 重启
docker compose down          # 停止
docker compose up -d --build # 重新构建并启动
```

---

## 方案三：Railway / Render 一键部署

### Railway

1. 打开 [railway.app](https://railway.app)
2. New Project → Deploy from GitHub repo
3. 选择这个仓库
4. 在 Variables 里添加环境变量：
   - `CAPY_EMAIL` / `CAPY_API_TOKEN`
   - `CAPY_PASSWORD`（邮箱模式）
   - `CAPY_PROJECT_ID`
   - `PROXY_API_KEY`
5. 自动部署，会给你一个公网 URL

### Render

1. 打开 [render.com](https://render.com)
2. New → Web Service → 连接 GitHub 仓库
3. Runtime: Node, Build Command 留空, Start Command: `node index.mjs`
4. 添加环境变量（同上）
5. 部署完成后得到公网 URL

---

## 部署后使用

假设你的服务地址是 `https://api.yourdomain.com`（或 `http://你的VPS-IP:3000`）：

### 打开管理面板

浏览器访问 `https://api.yourdomain.com`

### curl 测试

```bash
curl https://api.yourdomain.com/v1/chat/completions \
  -H "Authorization: Bearer 你的PROXY_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"model":"claude-sonnet-4-5","messages":[{"role":"user","content":"你好"}]}'
```

### Python

```python
from openai import OpenAI
client = OpenAI(base_url="https://api.yourdomain.com/v1", api_key="你的PROXY_API_KEY")
r = client.chat.completions.create(model="claude-sonnet-4-5", messages=[{"role":"user","content":"你好"}])
print(r.choices[0].message.content)
```

### aider

```bash
aider --openai-api-base https://api.yourdomain.com/v1 --openai-api-key 你的PROXY_API_KEY --model claude-opus-4-6
```

### ChatBox / NextChat 等客户端

- API 地址：`https://api.yourdomain.com/v1`
- API Key：你设置的 `PROXY_API_KEY`
- 模型：选 `claude-sonnet-4-5` 或 `auto`
