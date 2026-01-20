# User Documentation

- start VM
- `cd inception/`
- Run `make` in the repository root directory.
- Browse `https://login.42.fr`
- `curl -v http://anemet.42.fr` should not work (port 80 closed)
- `curl -v https://anemet.42.fr` works, but complains about self-signed certificate
- To ignore the self-signed certificate warning, use:
  ```bash
  curl -v -k https://anemet.42.fr:443
  
  # -k: Ignore self-signed certificate security warning.
  ```

