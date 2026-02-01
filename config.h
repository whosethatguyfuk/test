#ifndef VANITY_CONFIG
#define VANITY_CONFIG

static int const MAX_ITERATIONS = 100000000;
static int const STOP_AFTER_KEYS_FOUND = 1;

// how many times a gpu thread generates a public key in one go
__device__ const int ATTEMPTS_PER_EXECUTION = 100000;

__device__ const int MAX_PATTERNS = 1;

// prefix and suffix for "kai...kai" - both must match
__device__ static char const *prefixes[] = { "kai" };
__device__ static char const *suffixes[] = { "kai" };

#endif
