# docker-zipline-notebook
jupyter notebook image with zipline, pyfolio installed

## docker hub repo
https://hub.docker.com/r/timzhangau/zipline-notebook

### run jupyter notenook server
```bash
docker run -p 443:8888 -v /path/to/folder/saving/notebook/files:/projects -e PW_HASH="u'{YourHashedPasswordHere}'" -d timzhangau/zipline-notebook

```