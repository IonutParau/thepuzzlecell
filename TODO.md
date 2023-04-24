# Lua API internals

- Rewrite basically all of the Lua API's parameter-getting to not use top-based indexes (allows accidentally sending too many arguments not causing problematic behavior).
