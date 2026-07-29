# 🔐 权限中台管理系统

基于 RBAC 模型的权限中台，支持用户管理、项目管理和项目人员分配，三级角色权限控制。

---

## 🛠 技术栈

### 后端

| 技术 | 版本 | 说明 |
|---|---|---|
| Java | 21 (OpenJDK) | 项目内置 `java21/jdk-21.0.2` |
| Spring Boot | 3.1.12 | Web + Validation |
| MyBatis-Plus | 3.5.5 | ORM + 分页 + 逻辑删除 + 数据权限拦截 |
| MySQL | 8.0+ | 关系数据库 |
| JWT (jjwt) | 0.12.5 | 无状态认证 + 角色信息载荷 |
| BCrypt | 6.1.9 (spring-security-crypto) | 密码加密 |
| Maven | 3.9+ | 构建管理，使用项目内置 wrapper |

### 前端

| 技术 | 版本 | 说明 |
|---|---|---|
| Flutter | 3.44+ | 跨平台 UI 框架 |
| Provider | 6.1+ | 状态管理 |
| Dio | 5.4+ | HTTP 客户端 + 拦截器 |
| SharedPreferences | 2.2+ | Token 本地持久化 |
| 目标平台 | Windows 桌面 | — |

---

## 🖥 本地运行前置环境

| 软件 | 要求 | 说明 |
|---|---|---|
| JDK 21+ | ✅ 已内置 | `java21/jdk-21.0.2`，无需单独安装 |
| Maven 3.9+ | ✅ 已内置 | Maven Wrapper + 本地仓库 `m2_repo/` |
| MySQL 8.0+ | ⚠️ 需安装 | 端口 3306，root / 123456（可按需修改） |
| Flutter SDK 3.44+ | ⚠️ 需安装 | `C:\flutter\bin` 加入 PATH |
| Visual Studio 2022 | ⚠️ 需安装 | 勾选「使用 C++ 的桌面开发」工作负载 |

---

## 🗄 数据库部署

```sql
-- 1. 用 root 登录 MySQL
mysql -u root -p

-- 2. 执行初始化脚本（自动建库 + 建表 + 种子数据）
source admin_backend/src/main/resources/sql/init.sql
```

脚本会：
- 创建 `admin_platform` 数据库
- 创建 3 张表：`user`、`project`、`project_member`
- 插入 4 个内置测试用户

---

## 🚀 后端启动

```bash
cd admin_backend

# 设置 JDK 21
set JAVA_HOME=..\java21\jdk-21.0.2

# 构建（跳过测试）
mvnw package -DskipTests

# 启动
java -jar target\admin_backend-0.0.1-SNAPSHOT.jar
```

看到 `Started AdminBackendApplication` 表示启动成功，端口 `8080`。

> ⚠️ 首次启动后需调用初始化接口重置密码（数据库种子密码为无效哈希）：

```powershell
Invoke-RestMethod -Uri http://localhost:8080/api/auth/init -Method Post -Body '{"username":"superadmin","password":"123456"}' -ContentType "application/json"
Invoke-RestMethod -Uri http://localhost:8080/api/auth/init -Method Post -Body '{"username":"admin","password":"123456"}' -ContentType "application/json"
Invoke-RestMethod -Uri http://localhost:8080/api/auth/init -Method Post -Body '{"username":"employee1","password":"123456"}' -ContentType "application/json"
```

---

## 🎨 Flutter 桌面端启动

```bash
cd admin_flutter

# 安装依赖
flutter pub get

# 启动 Windows 桌面应用
flutter run -d windows
```

---

## 👥 内置测试账号

| 用户名 | 密码 | 角色 | 权限说明 |
|---|---|---|---|
| `superadmin` | `123456` | SUPER_ADMIN | 全部操作：用户 CRUD + 项目 CRUD + 人员分配 |
| `admin` | `123456` | ADMIN | 查看用户、创建项目、人员分配（不可新增/删除用户、不可删除项目） |
| `employee1` | `123456` | EMPLOYEE | 仅查看自己关联的项目（所有管理功能禁止） |
| `employee2` | `123456` | EMPLOYEE | 同 employee1 |

---

## 🔑 角色权限矩阵

| 功能 | SUPER_ADMIN | ADMIN | EMPLOYEE |
|---|---|---|---|
| 查看用户列表 | ✅ | ✅ | ❌ 403 |
| 新增用户 | ✅ | ❌ 403 | ❌ 403 |
| 编辑用户 | ✅ | ❌ 403 | ❌ 403 |
| 删除用户 | ✅ | ❌ 403 | ❌ 403 |
| 查看项目列表 | ✅ 全部 | ✅ 全部 | ✅ 仅自己关联的 |
| 查看项目详情 | ✅ | ✅ | ✅ 仅自己关联的 |
| 创建项目 | ✅ | ✅ | ❌ 403 |
| 编辑项目 | ✅ | ✅ 仅自己创建的 | ❌ 403 |
| 删除项目 | ✅ | ❌ 403 | ❌ 403 |
| 人员分配 | ✅ | ✅ 仅自己创建的项目 | ❌ 403 |
| 移除人员 | ✅ | ✅ 仅自己创建的项目 | ❌ 403 |
| 查看项目成员 | ✅ | ✅ | ✅ 仅自己关联的项目 |

---

## 📡 API 接口一览

### 认证
| 方法 | 路径 | 说明 | 鉴权 |
|---|---|---|---|
| POST | `/api/auth/init` | 初始化 / 重置密码 | 无 |
| POST | `/api/auth/login` | 登录，返回 JWT Token | 无 |
| GET | `/api/auth/me` | 获取当前用户信息 | Bearer Token |

### 用户管理
| 方法 | 路径 | 说明 |
|---|---|---|
| GET | `/api/users?pageNum=1&pageSize=10` | 分页查询 |
| GET | `/api/users/{id}` | 查询单个 |
| POST | `/api/users` | 新增 |
| PUT | `/api/users/{id}` | 修改 |
| DELETE | `/api/users/{id}` | 删除 |
| PUT | `/api/users/{id}/password` | 修改密码 |

### 项目管理
| 方法 | 路径 | 说明 |
|---|---|---|
| GET | `/api/projects?pageNum=1&pageSize=10` | 项目列表 |
| GET | `/api/projects/my` | 我的项目 |
| GET | `/api/projects/{id}` | 项目详情 |
| POST | `/api/projects` | 创建项目 |
| PUT | `/api/projects/{id}` | 修改项目 |
| DELETE | `/api/projects/{id}` | 删除项目 |
| POST | `/api/projects/{id}/members` | 分配人员 |
| DELETE | `/api/projects/{projectId}/members/{userId}` | 移除人员 |
| GET | `/api/projects/{id}/members` | 查看成员 |

---

## 📂 项目结构

```
admin_platform/
├── admin_backend/                # SpringBoot 后端
│   └── src/main/java/.../
│       ├── common/               # JWT、全局异常、上下文持有者
│       ├── config/               # 拦截器、MyBatis-Plus、密码编码器、数据权限
│       ├── controller/           # Auth、User、Project 控制器
│       ├── entity/               # User、Project、ProjectMember 实体
│       ├── enums/                # RoleEnum（SUPER_ADMIN / ADMIN / EMPLOYEE）
│       ├── mapper/               # MyBatis-Plus Mapper
│       ├── service/              # 业务接口与实现
│       └── resources/
│           ├── application.properties
│           └── sql/init.sql      # 数据库初始化脚本
│
├── admin_flutter/                # Flutter 桌面前端
│   └── lib/
│       ├── config/               # API 地址配置
│       ├── models/               # 数据模型（User、Project）
│       ├── services/             # Dio 网络层 + Token 拦截器
│       ├── providers/            # 状态管理（Auth、User、Project）
│       ├── pages/                # 登录、首页、用户管理、项目管理、人员分配
│       ├── widgets/              # 侧边栏、弹窗表单
│       └── utils/                # Token 本地持久化
│
├── java21/                       # JDK 21 运行时
└── m2_repo/                      # Maven 本地仓库
```

---

## 📄 License

MIT