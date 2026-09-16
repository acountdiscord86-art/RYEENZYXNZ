# Source Layout

`main.lua` is the standalone release file intended for direct loading.

The `src` folder is reserved for future modular source separation. The current release intentionally keeps the runtime library in one file so it can be loaded with a single `loadstring` request.
