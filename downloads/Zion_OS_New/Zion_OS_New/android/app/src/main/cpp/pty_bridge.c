#include <jni.h>
#include <unistd.h>
#include <stdlib.h>
#include <string.h>
#include <fcntl.h>
#include <termios.h>
#include <sys/wait.h>
#include <sys/ioctl.h>
#include <pthread.h>
#include <android/log.h>
#include <errno.h>

#define TAG "PtyBridge"
#define LOGI(...) __android_log_print(ANDROID_LOG_INFO, TAG, __VA_ARGS__)
#define LOGE(...) __android_log_print(ANDROID_LOG_ERROR, TAG, __VA_ARGS__)

typedef struct {
    int master_fd;
    int slave_fd;
    pid_t child_pid;
    char* output_buffer;
    int buffer_size;
    pthread_mutex_t buffer_mutex;
} PtyState;

JNIEXPORT jlong JNICALL
Java_com_zion_terminal_PtyManager_nativePtyOpen(JNIEnv* env, jobject thiz,
                                                  jint rows, jint cols,
                                                  jstring shellPath,
                                                  jobjectArray shellArgs) {
    PtyState* state = (PtyState*)calloc(1, sizeof(PtyState));
    if (!state) return 0;
    
    state->master_fd = posix_openpt(O_RDWR | O_NOCTTY);
    if (state->master_fd == -1) { LOGE("posix_openpt: %s", strerror(errno)); free(state); return 0; }
    
    grantpt(state->master_fd);
    unlockpt(state->master_fd);
    
    char* slave_name = ptsname(state->master_fd);
    state->slave_fd = open(slave_name, O_RDWR);
    if (state->slave_fd == -1) { LOGE("open slave: %s", strerror(errno)); close(state->master_fd); free(state); return 0; }
    
    struct winsize ws = { (unsigned short)rows, (unsigned short)cols, 0, 0 };
    ioctl(state->master_fd, TIOCSWINSZ, &ws);
    
    state->output_buffer = (char*)calloc(1, 65536);
    state->buffer_size = 0;
    pthread_mutex_init(&state->buffer_mutex, NULL);
    
    const char* shell = (*env)->GetStringUTFChars(env, shellPath, NULL);
    int argCount = (*env)->GetArrayLength(env, shellArgs);
    char** argv = (char**)calloc(argCount + 1, sizeof(char*));
    for (int i = 0; i < argCount; i++) {
        jstring arg = (jstring)(*env)->GetObjectArrayElement(env, shellArgs, i);
        argv[i] = (char*)(*env)->GetStringUTFChars(env, arg, NULL);
    }
    argv[argCount] = NULL;
    
    char* envp[] = {"TERM=xterm-256color", "HOME=/data/data/com.zion.os/files/home", NULL};
    
    pid_t pid = fork();
    if (pid == 0) {
        setsid();
        dup2(state->slave_fd, STDIN_FILENO);
        dup2(state->slave_fd, STDOUT_FILENO);
        dup2(state->slave_fd, STDERR_FILENO);
        ioctl(STDIN_FILENO, TIOCSCTTY, 0);
        close(state->master_fd);
        close(state->slave_fd);
        execve(shell, argv, envp);
        _exit(1);
    }
    
    state->child_pid = pid;
    close(state->slave_fd);
    LOGI("PTY created: master_fd=%d, pid=%d", state->master_fd, pid);
    return (jlong)state;
}

JNIEXPORT jstring JNICALL
Java_com_zion_terminal_PtyManager_nativePtyRead(JNIEnv* env, jobject thiz, jlong statePtr) {
    PtyState* state = (PtyState*)statePtr;
    if (!state) return (*env)->NewStringUTF(env, "");
    
    char temp[4096];
    int bytes = read(state->master_fd, temp, sizeof(temp) - 1);
    if (bytes > 0) {
        temp[bytes] = '\0';
        pthread_mutex_lock(&state->buffer_mutex);
        strcat(state->output_buffer, temp);
        pthread_mutex_unlock(&state->buffer_mutex);
        return (*env)->NewStringUTF(env, temp);
    }
    return (*env)->NewStringUTF(env, "");
}

JNIEXPORT void JNICALL
Java_com_zion_terminal_PtyManager_nativePtyWrite(JNIEnv* env, jobject thiz, jlong statePtr, jstring data) {
    PtyState* state = (PtyState*)statePtr;
    if (!state) return;
    const char* cmd = (*env)->GetStringUTFChars(env, data, NULL);
    write(state->master_fd, cmd, strlen(cmd));
    (*env)->ReleaseStringUTFChars(env, data, cmd);
}

JNIEXPORT void JNICALL
Java_com_zion_terminal_PtyManager_nativePtyResize(JNIEnv* env, jobject thiz, jlong statePtr, jint rows, jint cols) {
    PtyState* state = (PtyState*)statePtr;
    if (!state) return;
    struct winsize ws = { (unsigned short)rows, (unsigned short)cols, 0, 0 };
    ioctl(state->master_fd, TIOCSWINSZ, &ws);
    kill(state->child_pid, SIGWINCH);
}

JNIEXPORT void JNICALL
Java_com_zion_terminal_PtyManager_nativePtyClose(JNIEnv* env, jobject thiz, jlong statePtr) {
    PtyState* state = (PtyState*)statePtr;
    if (!state) return;
    kill(state->child_pid, SIGTERM);
    waitpid(state->child_pid, NULL, 0);
    close(state->master_fd);
    pthread_mutex_destroy(&state->buffer_mutex);
    free(state->output_buffer);
    free(state);
    LOGI("PTY closed");
}
