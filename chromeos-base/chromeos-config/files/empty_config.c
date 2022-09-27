#include "lib/cros_config_struct.h"

static struct config_map all_configs[] = {};

const struct config_map *cros_config_get_config_map(int *num_entries) {
  *num_entries = 0;
  return &all_configs[0];
}
