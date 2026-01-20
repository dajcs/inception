    *   Simple instructions: "Run `make`."
    *   "Go to `https://login.42.fr`."
    *   List the credentials (referenced from `.env` or secrets).


We can't edit `/etc/hosts`, so the browser doesn't know that `anemet.42.fr` points to localhost.
We can try in the browser to go to `https://localhost:443`, and it should work the same.

or the professional way, we can use `curl`:

```bash
curl -v -k --resolve anemet.42.fr:443:127.0.0.1 https://anemet.42.fr:443

# -k: Ignore self-signed certificate security warning.
# --resolve: Force DNS resolution.

```

