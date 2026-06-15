// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║                         Zion OS Terminal                                   ║
// ║                    PTY Handler - معالج PTY بلغة C                         ║
// ║                                                                            ║
// ║  Author: MiniMax Agent                                                     ║
// ║  Version: 1.0.0                                                            ║
// ║  Description: معالج PTY حقيقي لتشغيل bash والتعامل مع الطرفية              ║
// ╚═══════════════════════════════════════════════════════════════════════════╝

#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include <fcntl.h>
#include <termios.h>
#include <sys/ioctl.h>
#include <sys/wait.h>
#include <sys/select.h>
#include <pty.h>
#include <utmp.h>
#include <errno.h>
#include <signal.h>

// ═══════════════════════════════════════════════════════════════════════════
//                      الثوابت
// ═══════════════════════════════════════════════════════════════════════════

#define BUFFER_SIZE 4096
#define MAX_COMMAND_LENGTH 1024

// ═══════════════════════════════════════════════════════════════════════════
//                      هيكل PTY State
// ═══════════════════════════════════════════════════════════════════════════

typedef struct {
    int master_fd;
    int slave_fd;
    pid_t child_pid;
    int rows;
    int columns;
    char title[256];
    int is_running;
    int exit_status;
} PtyHandler;

// ═══════════════════════════════════════════════════════════════════════════
//                      دوال إنشاء PTY
// ═══════════════════════════════════════════════════════════════════════════

/// إنشاء PTY جديد
/// Create a new PTY pair
int pty_create(int *master_fd, int *slave_fd) {
    int master, slave;
    struct termios termios;
    struct winsize winsize;

    // فتح PTY الرئيسي
    master = posix_openpt(O_RDWR | O_NOCTTY);
    if (master == -1) {
        perror("posix_openpt");
        return -1;
    }

    // منح الوصول للـ slave PTY
    if (grantpt(master) == -1) {
        perror("grantpt");
        close(master);
        return -1;
    }

    // إلغاء قفل الـ slave PTY
    if (unlockpt(master) == -1) {
        perror("unlockpt");
        close(master);
        return -1;
    }

    // الحصول على اسم الـ slave PTY
    const char *slave_name = ptsname(master);
    if (slave_name == NULL) {
        perror("ptsname");
        close(master);
        return -1;
    }

    // فتح الـ slave PTY
    slave = open(slave_name, O_RDWR | O_NOCTTY);
    if (slave == -1) {
        perror("open slave");
        close(master);
        return -1;
    }

    // إعداد إعدادات الطرفية
    if (tcgetattr(master, &termios) == 0) {
        cfmakeraw(&termios);
        tcsetattr(master, TCSAFLUSH, &termios);
    }

    // إعداد حجم النافذة الافتراضي
    winsize.ws_row = 24;
    winsize.ws_col = 80;
    winsize.ws_xpixel = 0;
    winsize.ws_ypixel = 0;
    ioctl(master, TIOCSWINSZ, &winsize);

    *master_fd = master;
    *slave_fd = slave;

    return 0;
}

/// إنشاء معالج PTY جديد
/// Create a new PTY handler
PtyHandler *pty_handler_create(void) {
    PtyHandler *handler = (PtyHandler *)malloc(sizeof(PtyHandler));
    if (handler == NULL) {
        return NULL;
    }

    memset(handler, 0, sizeof(PtyHandler));
    handler->rows = 24;
    handler->columns = 80;
    handler->is_running = 0;
    strcpy(handler->title, "Zion Terminal");

    if (pty_create(&handler->master_fd, &handler->slave_fd) != 0) {
        free(handler);
        return NULL;
    }

    return handler;
}

// ═══════════════════════════════════════════════════════════════════════════
//                      دوال تشغيل العمليات
// ═══════════════════════════════════════════════════════════════════════════

/// تشغيل shell في PTY
/// Spawn a shell in the PTY
int pty_spawn_shell(PtyHandler *handler) {
    pid_t pid;

    if (handler == NULL || handler->master_fd < 0) {
        return -1;
    }

    pid = fork();

    if (pid < 0) {
        perror("fork");
        return -1;
    }

    if (pid == 0) {
        // عملية الابن
       pty_child_process(handler);
        // لن نصل إلى هنا
        exit(1);
    }

    // عملية الأب
    handler->child_pid = pid;
    handler->is_running = 1;

    return pid;
}

void pty_child_process(PtyHandler *handler) {
    struct termios termios;
    struct winsize winsize;

    // إنشاء جلسة جديدة
    setsid();

    // تعيين التحكم بالطرفية
    if (ioctl(handler->slave_fd, TIOCSCTTY, 0) == -1) {
        perror("ioctl TIOCSCTTY");
    }

    // إعادة توجيه المدخلات والمخرجات
    dup2(handler->slave_fd, STDIN_FILENO);
    dup2(handler->slave_fd, STDOUT_FILENO);
    dup2(handler->slave_fd, STDERR_FILENO);

    // إغلاق الـ fd غير المستخدم
    if (handler->slave_fd > STDERR_FILENO) {
        close(handler->slave_fd);
    }
    if (handler->master_fd > STDERR_FILENO) {
        close(handler->master_fd);
    }

    // الحصول على إعدادات الطرفية
    if (tcgetattr(STDIN_FILENO, &termios) == 0) {
        cfmakeraw(&termios);
        tcsetattr(STDIN_FILENO, TCSAFLUSH, &termios);
    }

    // إعداد حجم النافذة
    winsize.ws_row = handler->rows;
    winsize.ws_col = handler->columns;
    ioctl(STDIN_FILENO, TIOCSWINSZ, &winsize);

    // إعداد متغيرات البيئة
    setenv("TERM", "xterm-256color", 1);
    setenv("COLORTERM", "truecolor", 1);

    // تشغيل shell
    const char *shell = getenv("SHELL");
    if (shell == NULL) {
        shell = "/bin/bash";
    }

    execl(shell, shell, "-l", NULL);

    // إذا فشل exec
    perror("execl");
    exit(1);
}

/// تشغيل أمر محدد في PTY
/// Run a specific command in PTY
int pty_spawn_command(PtyHandler *handler, const char *command) {
    pid_t pid;

    if (handler == NULL || command == NULL) {
        return -1;
    }

    pid = fork();

    if (pid < 0) {
        perror("fork");
        return -1;
    }

    if (pid == 0) {
        // عملية الابن
        pty_child_process(handler);

        // تنفيذ الأمر
        execl("/bin/sh", "sh", "-c", command, NULL);

        perror("execl");
        exit(1);
    }

    // عملية الأب
    handler->child_pid = pid;
    handler->is_running = 1;

    return pid;
}

// ═══════════════════════════════════════════════════════════════════════════
//                      دوال القراءة والكتابة
// ═══════════════════════════════════════════════════════════════════════════

/// قراءة من PTY
/// Read from PTY
ssize_t pty_read(PtyHandler *handler, char *buffer, size_t size) {
    if (handler == NULL || buffer == NULL || handler->master_fd < 0) {
        return -1;
    }

    return read(handler->master_fd, buffer, size);
}

/// كتابة إلى PTY
/// Write to PTY
ssize_t pty_write(PtyHandler *handler, const char *data, size_t size) {
    if (handler == NULL || data == NULL || handler->master_fd < 0) {
        return -1;
    }

    return write(handler->master_fd, data, size);
}

/// كتابة أمر إلى PTY
/// Write a command to PTY
int pty_write_command(PtyHandler *handler, const char *command) {
    if (handler == NULL || command == NULL) {
        return -1;
    }

    size_t len = strlen(command);
    if (len == 0) {
        return 0;
    }

    // إضافة سطر جديد إذا لم يكن موجوداً
    char cmd[MAX_COMMAND_LENGTH];
    if (command[len - 1] != '\n') {
        snprintf(cmd, sizeof(cmd), "%s\n", command);
    } else {
        strncpy(cmd, command, sizeof(cmd) - 1);
        cmd[sizeof(cmd) - 1] = '\0';
    }

    return pty_write(handler, cmd, strlen(cmd));
}

// ═══════════════════════════════════════════════════════════════════════════
//                      دوال إدارة الحجم
// ═══════════════════════════════════════════════════════════════════════════

/// تغيير حجم PTY
/// Resize PTY
int pty_resize(PtyHandler *handler, int rows, int columns) {
    struct winsize winsize;

    if (handler == NULL || handler->master_fd < 0) {
        return -1;
    }

    if (rows <= 0 || columns <= 0) {
        return -1;
    }

    winsize.ws_row = (unsigned short)rows;
    winsize.ws_col = (unsigned short)columns;
    winsize.ws_xpixel = 0;
    winsize.ws_ypixel = 0;

    if (ioctl(handler->master_fd, TIOCSWINSZ, &winsize) == -1) {
        perror("ioctl TIOCSWINSZ");
        return -1;
    }

    handler->rows = rows;
    handler->columns = columns;

    return 0;
}

/// الحصول على حجم PTY الحالي
/// Get current PTY size
int pty_get_size(PtyHandler *handler, int *rows, int *columns) {
    struct winsize winsize;

    if (handler == NULL || handler->master_fd < 0) {
        return -1;
    }

    if (ioctl(handler->master_fd, TIOCGWINSZ, &winsize) == -1) {
        perror("ioctl TIOCGWINSZ");
        return -1;
    }

    if (rows != NULL) {
        *rows = winsize.ws_row;
    }
    if (columns != NULL) {
        *columns = winsize.ws_col;
    }

    return 0;
}

// ═══════════════════════════════════════════════════════════════════════════
//                      دوال انتظار العمليات
// ═══════════════════════════════════════════════════════════════════════════

/// انتظار انتهاء العملية الابن
/// Wait for child process to finish
int pty_wait(PtyHandler *handler) {
    int status;

    if (handler == NULL || handler->child_pid <= 0) {
        return -1;
    }

    if (waitpid(handler->child_pid, &status, 0) == -1) {
        perror("waitpid");
        return -1;
    }

    handler->is_running = 0;

    if (WIFEXITED(status)) {
        handler->exit_status = WEXITSTATUS(status);
    } else if (WIFSIGNALED(status)) {
        handler->exit_status = 128 + WTERMSIG(status);
    } else {
        handler->exit_status = -1;
    }

    return handler->exit_status;
}

/// انتظار غير محظور
/// Non-blocking wait
int pty_waitpid(PtyHandler *handler, int options) {
    int status;
    pid_t result;

    if (handler == NULL || handler->child_pid <= 0) {
        return -1;
    }

    result = waitpid(handler->child_pid, &status, options | WNOHANG);

    if (result == -1) {
        perror("waitpid");
        return -1;
    }

    if (result == 0) {
        // العملية لا تزال قيد التشغيل
        return 0;
    }

    // العملية انتهت
    handler->is_running = 0;

    if (WIFEXITED(status)) {
        handler->exit_status = WEXITSTATUS(status);
    } else if (WIFSIGNALED(status)) {
        handler->exit_status = 128 + WTERMSIG(status);
    } else {
        handler->exit_status = -1;
    }

    return handler->exit_status;
}

/// التحقق مما إذا كانت العملية لا تزال قيد التشغيل
/// Check if process is still running
int pty_is_running(PtyHandler *handler) {
    if (handler == NULL) {
        return 0;
    }

    if (!handler->is_running) {
        return 0;
    }

    // التحقق مما إذا كانت العملية موجودة
    if (kill(handler->child_pid, 0) == -1) {
        if (errno == ESRCH) {
            // العملية غير موجودة
            handler->is_running = 0;
            return 0;
        }
    }

    return 1;
}

// ═══════════════════════════════════════════════════════════════════════════
//                      دوال إرسال الإشارات
// ═══════════════════════════════════════════════════════════════════════════

/// إرسال إشارة للعملية
/// Send signal to process
int pty_kill(PtyHandler *handler, int signal) {
    if (handler == NULL || handler->child_pid <= 0) {
        return -1;
    }

    return kill(handler->child_pid, signal);
}

/// إيقاف العملية
/// Stop process
int pty_stop(PtyHandler *handler) {
    return pty_kill(handler, SIGSTOP);
}

/// استئناف العملية
/// Resume process
int pty_resume(PtyHandler *handler) {
    return pty_kill(handler, SIGCONT);
}

// ═══════════════════════════════════════════════════════════════════════════
//                      دوال تحديد
// ═══════════════════════════════════════════════════════════════════════════

/// إعداد fd_set للقراءة
/// Setup fd_set for reading
void pty_setup_fd_set(PtyHandler *handler, fd_set *read_fds, int *max_fd) {
    if (handler == NULL || read_fds == NULL) {
        return;
    }

    FD_ZERO(read_fds);
    FD_SET(handler->master_fd, read_fds);

    if (max_fd != NULL && handler->master_fd > *max_fd) {
        *max_fd = handler->master_fd;
    }
}

/// انتظار PTY مع timeout
/// Wait for PTY with timeout
int pty_wait_for_data(PtyHandler *handler, int timeout_ms) {
    fd_set read_fds;
    struct timeval tv;
    int max_fd = handler->master_fd;

    if (handler == NULL) {
        return -1;
    }

    FD_ZERO(&read_fds);
    FD_SET(handler->master_fd, &read_fds);

    tv.tv_sec = timeout_ms / 1000;
    tv.tv_usec = (timeout_ms % 1000) * 1000;

    int result = select(max_fd + 1, &read_fds, NULL, NULL, &tv);

    if (result > 0 && FD_ISSET(handler->master_fd, &read_fds)) {
        return 1;
    }

    return result;
}

// ═══════════════════════════════════════════════════════════════════════════
//                      دوال العنوان
// ═══════════════════════════════════════════════════════════════════════════

/// تعيين عنوان الطرفية
/// Set terminal title
int pty_set_title(PtyHandler *handler, const char *title) {
    if (handler == NULL || title == NULL) {
        return -1;
    }

    strncpy(handler->title, title, sizeof(handler->title) - 1);
    handler->title[sizeof(handler->title) - 1] = '\0';

    // إرسال sequence تغيير العنوان
    char title_seq[512];
    snprintf(title_seq, sizeof(title_seq), "\x1B]0;%s\x07", title);

    return pty_write(handler, title_seq, strlen(title_seq));
}

/// الحصول على عنوان الطرفية
/// Get terminal title
const char *pty_get_title(PtyHandler *handler) {
    if (handler == NULL) {
        return NULL;
    }
    return handler->title;
}

// ═══════════════════════════════════════════════════════════════════════════
//                      دوال التنظيف
// ═══════════════════════════════════════════════════════════════════════════

/// إغلاق PTY
/// Close PTY
int pty_close(PtyHandler *handler) {
    if (handler == NULL) {
        return -1;
    }

    // إيقاف العملية الابن إذا كانت قيد التشغيل
    if (handler->is_running && handler->child_pid > 0) {
        kill(handler->child_pid, SIGTERM);
        sleep(1);
        kill(handler->child_pid, SIGKILL);
        waitpid(handler->child_pid, NULL, 0);
    }

    // إغلاق الـ file descriptors
    if (handler->master_fd >= 0) {
        close(handler->master_fd);
        handler->master_fd = -1;
    }

    if (handler->slave_fd >= 0) {
        close(handler->slave_fd);
        handler->slave_fd = -1;
    }

    handler->is_running = 0;
    handler->child_pid = 0;

    return 0;
}

/// تحرير معالج PTY
/// Free PTY handler
void pty_handler_free(PtyHandler *handler) {
    if (handler == NULL) {
        return;
    }

    pty_close(handler);
    free(handler);
}

// ═══════════════════════════════════════════════════════════════════════════
//                      نهاية الملف
// ═══════════════════════════════════════════════════════════════════════════