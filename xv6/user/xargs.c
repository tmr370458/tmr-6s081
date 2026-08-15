#include "kernel/types.h"
#include "user/user.h"
#include "kernel/param.h"

int main(int argc, char *argv[]) {
    // 检查是否提供了命令
    if (argc < 2) {
        fprintf(2, "xargs: missing command\n");
        exit(1);
    }

    // 构造 exec 参数数组（固定参数 + 行参数）
    char *new_argv[MAXARG] = {0};
    for (int i = 1; i < argc; i++) {
        new_argv[i - 1] = argv[i];
    }
    // new_argv[argc-1] 留空，指向当前行

    char buf[512];
    int idx = 0;
    char c;
    int ret;

    while (1) {
        ret = read(0, &c, 1);

        // 处理读错误
        if (ret < 0) {
            fprintf(2, "xargs: read error\n");
            exit(1);
        }

        // 处理 EOF（文件末尾）
        if (ret == 0) {
            // 如果缓存中有内容，执行最后一行
            if (idx > 0) {
                buf[idx] = '\0';
                new_argv[argc - 1] = buf;
                new_argv[argc] = '\0';

                int pid = fork();
                if (pid == 0) {
                    exec(argv[1], new_argv);
                    fprintf(2, "xargs: exec failed\n");
                    exit(1);
                } else {
                    wait(0);
                }
            }
            break;  // 退出主循环
        }

        // 处理换行符
        if (c == '\n') {
            if (idx > 0) {
                buf[idx] = '\0';
                new_argv[argc - 1] = buf;
                new_argv[argc] = '\0';

                int pid = fork();
                if (pid == 0) {
                    exec(argv[1], new_argv);
                    fprintf(2, "xargs: exec failed\n");
                    exit(1);
                } else {
                    wait(0);
                }
            }
            // 重置行缓存（无需 memset，idx=0 即可）
            idx = 0;
            continue;
        }

        // 普通字符：写入 buf，注意防溢出
        if (idx < 511) {
            buf[idx++] = c;
        } else {
            fprintf(2, "xargs: line too long\n");
            exit(1);
        }
    }

    exit(0);
}