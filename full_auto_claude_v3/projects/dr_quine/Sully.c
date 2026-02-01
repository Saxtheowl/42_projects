#include<stdio.h>
char*s="#include<stdio.h>%cchar*s=%c%s%c;%cint main(){FILE*f=fopen(%cSully_1.c%c,%cw%c);if(f){fprintf(f,s,10,34,s,34,10,34,34,34,34,10);fclose(f);}return 0;}%c";
int main(){FILE*f=fopen("Sully_1.c","w");if(f){fprintf(f,s,10,34,s,34,10,34,34,34,34,10);fclose(f);}return 0;}
