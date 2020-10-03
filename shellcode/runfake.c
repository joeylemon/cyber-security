#include <unistd.h>
int main() {
	setuid(0);
	setgid(0);
	return execl ("./fake", "fake", NULL);
}
