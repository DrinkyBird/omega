#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int main (int argc, char* argv[]) {
	if (argc != 2) {
		fprintf (stderr, "usage: %s <description>\n", argv[0]);
		exit (EXIT_FAILURE);
	}
	
	char* a = strstr (argv[1], "-");
	char* b = (a && *(a + 1) != '\0') ? strstr (a + 1, "-") : NULL;
	
	if (!a || !b || b - a >= 16) {
		fprintf (stderr, "bad git description input\n");
		exit (EXIT_FAILURE);
	}
	
	char c[16];
	memcpy (c, a + 1, b - a - 1);
	c[b - a - 1] = '\0';
	printf ("%s\n", c);

	exit (EXIT_SUCCESS);
}
