#include<stdio.h>
char*n="Grace";char*s="#include<stdio.h>%cchar*n=%c%s%c;char*s=%c%s%c;%cint main(){printf(s,10,34,n,34,34,s,34,10,10);return 0;}%c";
int main(){printf(s,10,34,n,34,34,s,34,10,10);return 0;}
