/* file utilities that don't use the heap or fstat or static memory */

int getfile(const char *filename, int buflen, char buf[buflen]);
int filelen(char const *filename);
int numlines(int len, unsigned char buf[len]);
int fnumlines(const char *filename);
void lines(int len, unsigned char buf[len], int nlines, char *line[nlines]);
int linelen(char *p);
