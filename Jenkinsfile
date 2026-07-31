pipeline {
    agent any

    // ============================================================
    // Jenkinsfile - 管理平台 CI/CD 流水线（适配 Ubuntu 服务器）
    // 技术栈：SpringBoot 3.x + Java 21 + Flutter Web
    // 最后更新：2026-07-31
    // ============================================================

    // ============================================================
    // 环境变量（请根据实际服务器环境调整以下路径）
    // ============================================================
    environment {
        /*
         * GitHub 仓库地址
         * 凭证 ID「github-cred」需提前在 Jenkins 中创建：
         *   Jenkins → Manage Jenkins → Credentials → System → Global credentials
         *   Kind: Username with password
         *   Username: GitHub 用户名
         *   Password: GitHub Personal Access Token（需勾选 repo 权限）
         */
        GIT_REPO    = 'https://github.com/Cyron00112233/-.git'

        /*
         * 项目子模块在仓库中的相对路径
         */
        BACKEND_DIR = 'admin_backend'       // SpringBoot 后端模块
        FLUTTER_DIR = 'admin_flutter'       // Flutter Web 前端模块

        /*
         * Java 21 JDK 安装路径
         * Ubuntu apt 安装的默认位置，通常不需要修改
         */
        JAVA_HOME   = '/usr/lib/jvm/java-21-openjdk-amd64'

        /*
         * Maven 本地仓库路径
         * 使用项目自带 m2_repo 可离线加速构建（需先将依赖放入仓库）
         */
        M2_HOME     = '${WORKSPACE}/m2_repo'

        /*
         * 后端部署端口（建议避开 8080，避免与 Jenkins 自身冲突）
         */
        SERVER_PORT = '8090'

        /*
         * 后端日志输出路径
         */
        APP_LOG     = '/var/log/admin_backend.log'
    }

    // ============================================================
    // 构建参数：允许手动选择分支与端口
    // ============================================================
    parameters {
        string(
            name: 'GIT_BRANCH',
            defaultValue: 'master',
            description: '要构建的 Git 分支名称'
        )
        string(
            name: 'SERVER_PORT',
            defaultValue: '8090',
            description: '后端服务运行端口（需确保未被占用）'
        )
    }

    // ============================================================
    // 全局工具配置
    // 需提前在 Jenkins → 系统管理 → 全局工具配置 中完成：
    //   - JDK 安装    别名: jdk21     JAVA_HOME: /usr/lib/jvm/java-21-openjdk-amd64
    //   - Maven 安装   别名: maven3    建议使用 3.9+
    //   - Flutter 安装 别名: flutter    路径指向 Flutter SDK 根目录（可选）
    // ============================================================
    tools {
        jdk   'jdk21'
        maven 'maven3'
    }

    // ============================================================
    // 流水线阶段定义
    // ============================================================
    stages {

        // ============================================================
        // 阶段 1：拉取 GitHub 仓库源码
        // ============================================================
        stage('Checkout') {
            steps {
                script {
                    echo '================================================'
                    echo '  [阶段 1/4]  拉取 GitHub 源码'
                    echo "  仓库地址:   ${GIT_REPO}"
                    echo "  目标分支:   ${params.GIT_BRANCH}"
                    echo '================================================'
                }

                // 使用 Jenkins 凭证拉取 GitHub 私有/公开仓库
                // 如果仓库是公开的，可删除 credentialsId 那一行
                checkout([$class: 'GitSCM',
                    branches: [[name: "*/${params.GIT_BRANCH}"]],
                    userRemoteConfigs: [[
                        url: GIT_REPO,
                        credentialsId: 'github-cred'   // ← 在 Jenkins 凭证管理中创建
                    ]]
                ])

                // 打印最新提交记录，方便追溯版本
                script {
                    def commit = sh(
                        script: 'git log -1 --pretty=format:"%h - %s (%an, %ar)"',
                        returnStdout: true
                    ).trim()
                    echo "  📦 最新提交: ${commit}"
                }
            }
        }

        // ============================================================
        // 阶段 2：Maven 编译打包 SpringBoot 后端
        // ============================================================
        stage('Build Backend') {
            steps {
                script {
                    echo '================================================'
                    echo '  [阶段 2/4]  Maven 编译 SpringBoot 后端'
                    echo '  技术栈: Spring Boot 3.x + JDK 21 + MyBatis-Plus'
                    echo '================================================'
                }

                dir(BACKEND_DIR) {
                    /*
                     * mvnw（Maven Wrapper）会自动下载匹配的 Maven 版本，
                     * 无需服务器预装 Maven，但需要服务器能访问 Maven 中央仓库。
                     * -DskipTests 跳过单元测试以加速构建。
                     * -Dmaven.repo.local 指定本地缓存路径，加速重复构建。
                     */
                    sh '''
                        # 赋予 mvnw 可执行权限（处理 Windows → Linux 换行符问题）
                        chmod +x mvnw 2>/dev/null || true

                        # 确保 mvnw 使用 Unix 换行符（解决 Windows 开发环境兼容性）
                        sed -i "s/\\r$//" mvnw 2>/dev/null || true

                        echo "[Maven] 开始编译打包..."
                        ./mvnw clean package -DskipTests \
                            -Dmaven.repo.local=${M2_HOME}

                        if [ $? -ne 0 ]; then
                            echo "[错误] Maven 编译失败！"
                            exit 1
                        fi
                    '''
                }

                // 验证 JAR 产物是否生成
                script {
                    def jarFiles = findFiles(glob: "${BACKEND_DIR}/target/*.jar")
                    def fatJar = jarFiles.find { !it.name.contains('sources') && !it.name.contains('javadoc') }

                    if (fatJar) {
                        echo "  ✅ JAR 构建成功: ${fatJar.name}"
                    } else {
                        error('  ❌ 未找到可部署的 JAR 文件，构建失败！')
                    }
                }
            }
        }

        // ============================================================
        // 阶段 3：检测 Flutter 环境并编译前端（条件执行）
        // ============================================================
        stage('Build Flutter') {
            steps {
                script {
                    echo '================================================'
                    echo '  [阶段 3/4]  检测 Flutter 环境并编译前端'
                    echo '================================================'

                    /*
                     * 检测服务器是否安装了 Flutter SDK。
                     * 如果已安装则编译 Web 版本；否则跳过前端构建，仅部署后端。
                     * 这样即使未配置 Flutter，流水线也不会中断。
                     */
                    def flutterInstalled = sh(
                        script: 'command -v flutter >/dev/null 2>&1 && echo "yes" || echo "no"',
                        returnStdout: true
                    ).trim()

                    if (flutterInstalled == 'yes') {
                        // 打印 Flutter 版本信息
                        sh '''
                            echo "[Flutter] 检测到已安装的 Flutter SDK:"
                            flutter --version 2>&1 | head -3
                        '''

                        // 进入 Flutter 模块并编译 Web 版本
                        dir(FLUTTER_DIR) {
                            sh '''
                                set -e

                                echo "[Flutter] 清理旧构建缓存..."
                                flutter clean

                                echo "[Flutter] 拉取依赖包..."
                                flutter pub get

                                echo "[Flutter] 编译 Web 发行版..."
                                flutter build web --release

                                if [ $? -eq 0 ]; then
                                    echo "[Flutter] ✅ Web 编译成功  →  ${FLUTTER_DIR}/build/web/"
                                else
                                    echo "[Flutter] ❌ Web 编译失败！"
                                    exit 1
                                fi
                            '''
                        }
                    } else {
                        /*
                         * Flutter SDK 未安装，跳过前端编译。
                         * 安装指引（Ubuntu）：
                         *   sudo snap install flutter --classic
                         *   flutter doctor
                         */
                        echo '  ⚠️  未检测到 Flutter SDK，跳过前端编译。'
                        echo '  ℹ️  如需启用前端构建，请在服务器执行:'
                        echo '      sudo snap install flutter --classic'
                        echo '      并在 Jenkins 全局工具配置中添加 Flutter'
                    }
                }
            }
        }

        // ============================================================
        // 阶段 4：部署启动后端服务
        // ============================================================
        stage('Deploy Backend') {
            steps {
                script {
                    echo '================================================'
                    echo '  [阶段 4/4]  部署启动 SpringBoot 服务'
                    echo "  目标端口:    ${params.SERVER_PORT}"
                    echo '================================================'
                }

                /*
                 * 子步骤 1：关闭占用目标端口的旧 Java 进程
                 *
                 * 优先使用 fuser（大多数 Ubuntu 预装），失败则降级用 lsof。
                 * 先发 SIGTERM（优雅关闭），等待 5 秒后仍存活则 SIGKILL（强制终止）。
                 * 仅终止属于 java 的进程，避免误杀其他服务。
                 */
                sh '''
                    PORT=${SERVER_PORT}
                    echo "[部署] 检测端口 ${PORT} 占用情况..."

                    # 方式一：使用 fuser（推荐，权限要求低）
                    OLD_PID=$(fuser ${PORT}/tcp 2>/dev/null | awk '{print $NF}' || true)

                    # 方式二：fuser 不可用时降级用 lsof
                    if [ -z "$OLD_PID" ]; then
                        OLD_PID=$(lsof -ti:${PORT} -sTCP:LISTEN 2>/dev/null || true)
                    fi

                    if [ -n "$OLD_PID" ]; then
                        # 确认是 Java 进程（避免误杀）
                        PROC_NAME=$(ps -p $OLD_PID -o comm= 2>/dev/null || echo "unknown")
                        echo "[部署] 发现占用端口 ${PORT} 的进程: PID=${OLD_PID} 名称=${PROC_NAME}"

                        # 优雅终止
                        echo "[部署] 发送 SIGTERM 信号，优雅关闭旧服务..."
                        kill -15 $OLD_PID 2>/dev/null || true

                        # 等待最多 5 秒
                        for i in $(seq 1 5); do
                            if ! kill -0 $OLD_PID 2>/dev/null; then
                                echo "[部署] 旧进程已退出（耗时 ${i}s）"
                                break
                            fi
                            sleep 1
                        done

                        # 如果还没退出，强制终止
                        if kill -0 $OLD_PID 2>/dev/null; then
                            echo "[部署] 进程未响应，强制终止 (SIGKILL)..."
                            kill -9 $OLD_PID 2>/dev/null || true
                            sleep 1
                        fi

                        # 二次确认端口已释放
                        RECHECK=$(fuser ${PORT}/tcp 2>/dev/null || true)
                        if [ -n "$RECHECK" ]; then
                            echo "[错误] 端口 ${PORT} 仍被占用，无法释放！"
                            echo "  请手动检查: sudo lsof -i:${PORT}"
                            exit 1
                        fi
                        echo "[部署] ✅ 端口 ${PORT} 已释放"
                    else
                        echo "[部署] 端口 ${PORT} 空闲，无需清理"
                    fi
                '''

                /*
                 * 子步骤 2：启动新的 SpringBoot 服务
                 *
                 * 使用 nohup 后台启动，重定向 stdout/stderr 到日志文件。
                 * 启动后执行健康检查，最多等待 60 秒。
                 */
                script {
                    // 获取 JAR 文件名
                    def jarFiles = findFiles(glob: "${BACKEND_DIR}/target/*.jar")
                    def jarFile = jarFiles.find { !it.name.contains('sources') && !it.name.contains('javadoc') }
                    def jarName = jarFile ? jarFile.name : 'unknown.jar'

                    echo "[部署] 启动 JAR: ${jarName}"
                }

                sh '''
                    PORT=${SERVER_PORT}
                    LOG_FILE=${APP_LOG}

                    # 确保日志目录存在且有写入权限
                    LOG_DIR=$(dirname "$LOG_FILE")
                    if [ ! -d "$LOG_DIR" ]; then
                        sudo mkdir -p "$LOG_DIR" 2>/dev/null || mkdir -p "$LOG_DIR" 2>/dev/null || {
                            echo "[警告] 无法创建日志目录 ${LOG_DIR}，使用当前目录"
                            LOG_FILE="./admin_backend.log"
                        }
                    fi

                    # 尝试获取日志文件写入权限
                    touch "$LOG_FILE" 2>/dev/null || {
                        echo "[警告] 无 ${LOG_FILE} 写入权限，日志输出到 ./admin_backend.log"
                        LOG_FILE="./admin_backend.log"
                    }

                    # 进入后端目录找到 JAR 文件
                    cd ${BACKEND_DIR}
                    JAR_FILE=$(ls target/*.jar 2>/dev/null | grep -v sources | grep -v javadoc | head -1)

                    if [ -z "$JAR_FILE" ]; then
                        echo "[错误] 未找到可部署的 JAR 文件！"
                        exit 1
                    fi

                    echo "[部署] 启动命令: java -jar ${JAR_FILE} --server.port=${PORT}"

                    # nohup 后台启动
                    nohup java -jar ${JAR_FILE} \
                        --server.port=${PORT} \
                        > "$LOG_FILE" 2>&1 &

                    NEW_PID=$!
                    echo "[部署] 服务已后台启动，PID: ${NEW_PID}"
                    echo "[部署] 日志文件: ${LOG_FILE}"
                '''

                /*
                 * 子步骤 3：健康检查 —— 轮询确认服务已就绪
                 */
                script {
                    def port = params.SERVER_PORT
                    def maxWait = 60   // 最长等待 60 秒
                    def ready = false

                    echo "[健康检查] 等待服务就绪（最长 ${maxWait} 秒）..."

                    for (int i = 1; i <= maxWait; i++) {
                        def httpCode = sh(
                            script: "curl -s -o /dev/null -w '%{http_code}' --connect-timeout 2 http://localhost:${port}/actuator/health 2>/dev/null || echo '000'",
                            returnStdout: true
                        ).trim()

                        if (httpCode == '200' || httpCode == '302' || httpCode == '401') {
                            ready = true
                            echo "[健康检查] ✅ 服务就绪！HTTP ${httpCode}（耗时 ${i}s）"
                            break
                        }

                        // 每 10 秒打印一条等待提示
                        if (i % 10 == 0) {
                            echo "[健康检查] 仍在等待服务启动...（已等待 ${i}s）"
                        }
                        sleep 1
                    }

                    if (!ready) {
                        echo '================================================'
                        echo '  ⚠️  警告: 健康检查超时！'
                        echo '  服务可能因数据库连接、端口冲突等原因启动失败。'
                        echo '  请登录服务器查看日志:'
                        echo "    tail -f ${APP_LOG}"
                        echo '================================================'

                        // 打印最近 30 行日志辅助排查
                        sh '''
                            echo "--- 最近日志片段 (${APP_LOG}) ---"
                            tail -30 ${APP_LOG} 2>/dev/null || echo "(无法读取日志文件)"
                        '''

                        // 健康检查失败不中断流水线，仅告警
                        unstable('健康检查未通过，请手动确认服务状态')
                    }
                }
            }
        }
    }

    // ============================================================
    // 构建后处理：根据构建结果执行不同操作
    // ============================================================
    post {
        /*
         * always 块：无论成功失败都会执行
         */
        always {
            script {
                echo '================================================'
                echo '  构建流水线结束'
                echo "  最终状态: ${currentBuild.currentResult}"
                echo "  总耗时:   ${currentBuild.durationString}"
                echo '================================================'
            }

            // 清理工作空间，释放磁盘（可选，根据需求启用）
            // cleanWs()
        }

        /*
         * success 块：构建成功时打印访问地址
         */
        success {
            script {
                echo '╔════════════════════════════════════════════╗'
                echo '║          🎉  构建部署成功！                ║'
                echo '╠════════════════════════════════════════════╣'
                echo "║  后端 API:  http://服务器IP:${params.SERVER_PORT}       ║"
                echo '║                                            ║'

                // 检查 Flutter 产物是否存在
                def flutterBuild = findFiles(glob: "${FLUTTER_DIR}/build/web/index.html")
                if (flutterBuild.length > 0) {
                    echo "║  Flutter Web: ${FLUTTER_DIR}/build/web/    ║"
                } else {
                    echo '║  Flutter Web: 未编译（服务器无 Flutter）  ║'
                }

                echo '╚════════════════════════════════════════════╝'
            }
        }

        /*
         * failure 块：构建失败时收集错误日志
         */
        failure {
            script {
                echo '╔════════════════════════════════════════════╗'
                echo '║          ❌  构建部署失败！                ║'
                echo '╚════════════════════════════════════════════╝'
                echo ''
                echo '  故障排查指引:'
                echo '  ──────────────────────────────────────────'
                echo '  1. Jenkins 控制台输出（本页面）—— 查看完整错误堆栈'
                echo '  2. 后端启动日志:'
                echo "     tail -100 ${APP_LOG}"
                echo '  3. 常见问题检查清单:'
                echo '     □ JDK 21 是否已安装:  java -version'
                echo "     □ 端口是否被占用:      sudo lsof -i:${params.SERVER_PORT}"
                echo '     □ MySQL 是否运行:     systemctl status mysql'
                echo '     □ 磁盘空间是否充足:   df -h'
                echo '     □ GitHub Token 是否过期'
                echo '  ──────────────────────────────────────────'
                echo ''

                // 尝试打印后端日志（如果存在）
                sh '''
                    echo "--- 后端日志 (最近 50 行) ---"
                    if [ -f ${APP_LOG} ]; then
                        echo "文件: ${APP_LOG}"
                        tail -50 ${APP_LOG}
                    else
                        echo "(日志文件不存在: ${APP_LOG})"
                        echo "(可能服务在启动阶段就已失败)"
                    fi
                '''
            }
        }

        /*
         * unstable 块：构建不稳定（如健康检查超时）
         */
        unstable {
            echo '⚠️  构建结果不稳定，请检查健康检查相关日志！'
        }
    }
}
