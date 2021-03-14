#include "count.h"
#include <stdio.h>

static int count = 0;

void print_count(void)
{
    count++;
    printf("Count: %d\n", count);
}
