# Lua API internals

- Rewrite basically all of the Lua API's parameter-getting to not use top-based indexes (allows accidentally sending too many arguments not causing problematic behavior).

# TPC Internals

- Rework subtick system to be based on a priority system with priority as numbers and self-sorting. (Likely in 2.3.1.0 - 2.4.0.0)

# TPC Performance Improvements

- Make multiple down-scaled versions of the grid's background sprite to save rendering time
