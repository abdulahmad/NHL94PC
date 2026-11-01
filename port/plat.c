/* plat.c: CPU and GPU use of this process for the stats display (from the NHL 95 port's plat_win.c). On Linux only the CPU. */
#include "host.h"
#ifdef _WIN32
#include <pdh.h>
#include <pdhmsg.h>

int plat_cpu_percent(void)
{
  static ULONGLONG last_cpu, last_wall;
  FILETIME c, e, k, u, now;
  SYSTEM_INFO si;
  ULONGLONG cpu, wall;
  int pct = -1;
  if (!GetProcessTimes(GetCurrentProcess(), &c, &e, &k, &u)) return -1;
  GetSystemTimeAsFileTime(&now);
  GetSystemInfo(&si);
  cpu = (((ULONGLONG)k.dwHighDateTime << 32) | k.dwLowDateTime) + (((ULONGLONG)u.dwHighDateTime << 32) | u.dwLowDateTime);
  wall = ((ULONGLONG)now.dwHighDateTime << 32) | now.dwLowDateTime;
  if (last_wall && wall > last_wall && si.dwNumberOfProcessors) pct = (int)((cpu - last_cpu) * 100 / ((wall - last_wall) * si.dwNumberOfProcessors));
  last_cpu = cpu; last_wall = wall;
  return pct > 100 ? 100 : pct;
}

/* the GPU engines of this process, from the performance counters Task Manager uses (Windows 10 and later) */
int plat_gpu_percent(void)
{
  static PDH_HQUERY q;
  static PDH_HCOUNTER counter;
  static int tried;
  DWORD size = 0, count = 0, i;
  PDH_FMT_COUNTERVALUE_ITEM_W *items;
  double sum = 0;
  if (!tried) {
    wchar_t path[128];
    tried = 1;
    _snwprintf(path, 128, L"\\GPU Engine(pid_%lu*engtype_3D)\\Utilization Percentage", (unsigned long)GetCurrentProcessId());
    if (PdhOpenQueryW(NULL, 0, &q) != ERROR_SUCCESS || PdhAddEnglishCounterW(q, path, 0, &counter) != ERROR_SUCCESS) { q = NULL; return -1; }
  }
  if (!q) return -1;
  if (PdhCollectQueryData(q) != ERROR_SUCCESS) return -1;
  if (PdhGetFormattedCounterArrayW(counter, PDH_FMT_DOUBLE, &size, &count, NULL) != (DWORD)PDH_MORE_DATA || !size) return 0;
  items = malloc(size);
  if (!items) return -1;
  if (PdhGetFormattedCounterArrayW(counter, PDH_FMT_DOUBLE, &size, &count, items) == ERROR_SUCCESS)
    for (i = 0; i < count; i++) sum += items[i].FmtValue.doubleValue;
  free(items);
  return sum > 100 ? 100 : (int)(sum + 0.5);
}
#else
#include <sys/resource.h>
#include <time.h>
#include <unistd.h>

int plat_cpu_percent(void)
{
  static double last_cpu, last_wall;
  struct rusage ru;
  struct timespec ts;
  double cpu, wall;
  long n = sysconf(_SC_NPROCESSORS_ONLN);
  int pct = -1;
  if (getrusage(RUSAGE_SELF, &ru)) return -1;
  clock_gettime(CLOCK_MONOTONIC, &ts);
  cpu = ru.ru_utime.tv_sec + ru.ru_utime.tv_usec * 1e-6 + ru.ru_stime.tv_sec + ru.ru_stime.tv_usec * 1e-6;
  wall = ts.tv_sec + ts.tv_nsec * 1e-9;
  if (last_wall > 0 && wall > last_wall && n > 0) pct = (int)((cpu - last_cpu) * 100 / ((wall - last_wall) * n));
  last_cpu = cpu; last_wall = wall;
  return pct > 100 ? 100 : pct;
}

int plat_gpu_percent(void) { return -1; }
#endif
