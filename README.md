# 🔐 权限中台管理系统

基于 RBAC 模型的权限中台，提供用户管理、项目管理、项目人员分配等核心功能，支持三级角色权限控制。

---

## 🛠 技术栈

| 层 | 技术 | 版本 |
|---|---|---|
| **后端框架** | Spring Boot | 3.1.12 |
| **ORM** | MyBatis-Plus | 3.5.5 |
| **安全** | JWT (jjwt) + BCrypt | 0.12.5 |
| **数据库** | MySQL | 8.0+ |
| **构建工具** | Maven | 3.9+ |
| **JDK** | OpenJDK | 21 |
| **前端框架** | Flutter | 3.44.8 |
| **状态管理** | Provider | 6.1+ |
| **HTTP 客户端** | Dio | 5.4+ |
| **桌面平台** | Windows (Win32) | — |

---

## 📁 项目结构

```
admin_platform/
├── admin_backend/          # SpringBoot 后端
│   ├── src/main/java/.../common/     # JWT 工具、全局异常、上下文持有者
│   ├── src/main/java/.../config/     # 拦截器、MyBatis-Plus、密码编码器
│   ├── src/main/java/.../controller/ # Auth、User、Project 控制器
│   ├── src/main/java/.../entity/     # User、Project、ProjectMember 实体
│   ├── src/main/java/.../enums/      # 角色枚举 (SUPER_ADMIN/ADMIN/EMPLOYEE)
│   ├── src/main/java/.../mapper/     # MyBatis-Plus Mapper
│   ├── src/main/java/.../service/    # 业务服务接口与实现
│   ├── src/main/resources/sql/init.sql  # 数据库初始化脚本
│   └── pom.xml
│
├── admin_flutter/           # Flutter 桌面前端
│   └── lib/
│       ├── config/          # API 配置
│       ├── models/          # 数据模型 (User, Project)
│       ├── services/        # Dio 网络层 + 拦截器
│       ├── providers/       # 状态管理 (Auth, User, Project)
│       ├── pages/           # 页面 (登录、首页、用户管理、项目管理、人员分配)
│       ├── widgets/         # 组件 (侧边栏、弹窗表单)
│       └── utils/           # Token 持久化工具
│
├── java21/                  # JDK 21 本地运行时
└── m2_repo/                 # Maven 本地仓库
```

---

## 🖥 本地环境要求

| 软件 | 要求 | 说明 |
|---|---|---|
| **JDK** | 21+ | 项目内置 `java21/jdk-21.0.2` |
| **Maven** | 3.9+ | 使用项目内置 Maven Wrapper |
| **MySQL** | 8.0+ | 端口 3306，用户名 root / 密码 123456 |
| **Flutter SDK** | 3.44+ | 需安装 Visual Studio 2022 + C++ 桌面开发 |
| **Visual Studio** | 2022 | 勾选"使用 C++ 的桌面开发"工作负载 |

---

## 🗄 数据库初始化

```bash
# 1. 启动 MySQL，使用 root 登录
mysql -u root -p

# 2. 执行初始化脚本
source admin_backend/src/main/resources/sql/init.sql
```

脚本会自动创建 `admin_platform` 数据库、3 张表（user / project / project_member）及 4 个种子用户。

---

## 🚀 后端启动

```bash
cd admin_backend

# 方式一：一键启动（Windows）
一键构建并启动.bat

# 方式二：手动构建
set JAVA_HOME=..\java21\jdk-21.0.2
mvnw package -DskipTests
java -jar target\admin_backend-0.0.1-SNAPSHOT.jar
```

后端启动后访问 `http://localhost:8080`，首次使用需调用初始化接口重置密码：

```bash
curl -X POST http://localhost:8080/api/auth/init \
  -H "Content-Type: application/json" \
  -d '{"username":"superadmin","password":"123456"}'
```

---

## 🎨 前端启动

```bash
cd admin_flutter

# 安装依赖
flutter pub get

# 启动 Windows 桌面端
flutter run -d windows
```

---

## 👥 内置测试账号

| 用户名 | 密码 | 角色 | 权限范围 |
|---|---|---|---|
| `superadmin` | `123456` | 超级管理员 | 全部操作（用户 CRUD + 项目 CRUD + 人员分配） |
| `admin` | `123456` | 管理员 | 查看用户、创建项目、人员分配（不可新增/删除用户、不可删除项目） |
| `employee1` | `123456` | 员工 | 仅查看自己的项目（不可管理用户、不可创建/删除项目） |
| `employee2` | `123456` | 员工 | 同 employee1 |

---

## 🔑 角色权限矩阵

| 功能 | SUPER_ADMIN | ADMIN | EMPLOYEE |
|---|---|---|---|
| 查看用户列表 | ✅ | ✅ | ❌ |
| 新增用户 | ✅ | ❌ | ❌ |
| 编辑用户 | ✅ | ❌ | ❌ |
| 删除用户 | ✅ | ❌ | ❌ |
| 查看项目列表 | ✅ | ✅ | ✅（仅自己关联的） |
| 创建项目 | ✅ | ✅ | ❌ |
| 编辑项目 | ✅ | ✅（仅自己创建的） | ❌ |
| 删除项目 | ✅ | ❌ | ❌ |
| 人员分配 | ✅ | ✅（仅自己创建的项目） | ❌ |

---

## 📡 API 接口

### 认证
| 方法 | 路径 | 说明 | 鉴权 |
|---|---|---|---|
| POST | `/api/auth/init` | 初始化/重置密码 | ❌ |
| POST | `/api/auth/login` | 登录获取 Token | ❌ |
| GET | `/api/auth/me` | 获取当前用户信息 | ✅ |

### 用户管理
| 方法 | 路径 | 说明 | 角色 |
|---|---|---|---|
| GET | `/api/users` | 分页查询用户 | 超管/管理员 |
| GET | `/api/users/{id}` | 查询单个用户 | — |
| POST | `/api/users` | 新增用户 | 超管 |
| PUT | `/api/users/{id}` | 修改用户 | 超管 |
| DELETE | `/api/users/{id}` | 删除用户 | 超管 |
| PUT | `/api/users/{id}/password` | 修改密码 | 本人/超管 |

### 项目管理
| 方法 | 路径 | 说明 | 角色 |
|---|---|---|---|
| GET | `/api/projects` | 项目列表 | — |
| GET | `/api/projects/{id}` | 项目详情 | — |
| POST | `/api/projects` | 创建项目 | 超管/管理员 |
| PUT | `/api/projects/{id}` | 修改项目 | 超管/创建者 |
| DELETE | `/api/projects/{id}` | 删除项目 | 超管 |
| POST | `/api/projects/{id}/members` | 分配人员 | 超管/管理员 |
| DELETE | `/api/projects/{projectId}/members/{userId}` | 移除人员 | 超管/管理员 |
| GET | `/api/projects/{id}/members` | 查看成员 | — |

---

## 📄 License

MIT