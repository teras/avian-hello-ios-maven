#include <stdint.h>
#include <stdlib.h>

void __cxa_pure_virtual(void) { abort(); }


#define EXPORT __attribute__ ((visibility("default"))) __attribute__ ((used))

#define BOOTIMAGE_BIN(x) _binary_bootimage_bin_##x
#define CODEIMAGE_BIN(x) _binary_codeimage_bin_##x

extern const uint8_t BOOTIMAGE_BIN(start)[];
extern const uint8_t BOOTIMAGE_BIN(end)[];

EXPORT const uint8_t*
bootimageBin(unsigned* size)
{
  *size = BOOTIMAGE_BIN(end) - BOOTIMAGE_BIN(start);
  return BOOTIMAGE_BIN(start);
}

extern const uint8_t CODEIMAGE_BIN(start)[];
extern const uint8_t CODEIMAGE_BIN(end)[];

EXPORT const uint8_t*
codeimageBin(unsigned* size)
{
  *size = CODEIMAGE_BIN(end) - CODEIMAGE_BIN(start);
  return CODEIMAGE_BIN(start);
}

#define RESOURCES_JAR(x) _binary_resources_jar_##x

extern const uint8_t RESOURCES_JAR(start)[];
extern const uint8_t RESOURCES_JAR(end)[];

EXPORT const uint8_t*
resourcesJar(unsigned* size)
{
  *size = RESOURCES_JAR(end) - RESOURCES_JAR(start);
  return RESOURCES_JAR(start);
}


