#include "greet/greet.h"

int main(int argc, char *argv[argc])
{
	if (argc < 2)
	{
		printf("Use: %s name\n", argv[0]);
		return 0;
	}

	return greet(argv[1]);
}
