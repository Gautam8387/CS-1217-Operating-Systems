#include "types.h"
#include "user.h"
#include "date.h"
// #include "printf.c"

int
main(int argc, char *argv[])
{
  struct rtcdate r;

  if (date(&r)) {
    // 2 is file descriptor for stderr
    printf(2, "date failed\n");
    exit();
  }
  // Edit Starts Here
  // 1 is file descriptor for stdout
  printf(1, "Year: %d\nMonth: %d\nDay: %d\nHour : Minute : Seconds :: %d:%d:%d\n", r.year, r.month, r.day, r.hour, r.minute, r.second);
  // Edit Ends Here
  exit();
}
/* 
The first printf() statement inside if condition writes to file descripter 2, which is stderr.
The second printf() statement writes to output, through file descriptor 1, which is stdout
*/