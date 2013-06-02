#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdexcept>

template<class T> T min (T a, T b) {
	return (a < b) ? a : b;
}

int main (int argc, char* argv[]) {
	if (argc != 3) {
		fprintf (stderr, "usage: %s <string> <numchars>\n", argv[0]);
		exit (EXIT_FAILURE);
	}
	
	int numbytes = min<int> (strlen (argv[1]), atoi (argv[2]));
	char* c;

	try {
		c = new char[numbytes + 1];
	} catch (std::bad_alloc& e) {
		fprintf (stderr, "%s: error: couldn't allocate %d bytes\n", argv[0], numbytes + 1);
		exit (EXIT_FAILURE);
	}
	
	for (int i = 0; i < numbytes; ++i) {
		c[i] = argv[1][i];
	}
	
	printf ("%s\n", c);
	delete[] c;
	
	exit (EXIT_SUCCESS);
}
