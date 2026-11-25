#include <signal.h>
#include <unistd.h>

extern char **environ;

/*
 * Wrapper for vendor.samsung.hardware.camera.provider@4.0-service_64.
 *
 * libsecril-client.so (used by com.qti.chi.override.so for Adaptive MIPI)
 * writes to a RILD UNIX domain socket (VND_Multiclient) that can be closed
 * by the peer, triggering EPIPE and an unhandled SIGPIPE that kills the
 * entire camera provider process.
 *
 * Setting SIGPIPE to SIG_IGN is preserved across execve() (POSIX), allowing
 * write() to return -1/EPIPE so libsecril-client.so handles the error cleanly.
 */
int main(int argc, char **argv) {
    (void)argc;
    signal(SIGPIPE, SIG_IGN);
    execve("/odm/bin/sec-cam-provider-orig", argv, environ);
    return 127;
}
