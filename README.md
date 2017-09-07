# home1-oss

## manual local or internal build and deploy

```bash
cd src/gitbook
./book.sh build
BUILD_PUBLISH_CHANNEL=snapshot ./book.sh deploy local
```

or

```bash
#bash ci.sh book_build "../../../"
bash ci.sh gitbook_build
bash ci.sh book_deploy "local"
```

## test travis-ci build at local

```bash
bash -x ci.sh gitbook_build
bash -x ci.sh book_deploy_prepare_github_ghpages "snapshot" "home1-oss-gitbook" "https://${GITHUB_INFRASTRUCTURE_CONF_GIT_TOKEN}:x-oauth-basic@github.com/home1-oss-gitbook"
```
