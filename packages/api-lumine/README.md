# api-lumine

just a bunch of rust code doing its thing.

used to get shiny stuff moving on my website mainly

## fixing the spotify token

every 6 months, need to update spotify refresh token else we get `INTERNAL ERROR [get_token]: spotify auth api returned unexpected status: 400 Bad Request`.

replace client id by the real client id [https://accounts.spotify.com/authorize?client_id=CLIENT_ID_HERE&response_type=code&redirect_uri=http://127.0.0.1:8888/callback&scope=user-read-currently-playing](https://accounts.spotify.com/authorize?client_id=CLIENT_ID_HERE&response_type=code&redirect_uri=http://127.0.0.1:8888/callback&scope=user-read-currently-playing)

get the string after `?code=`

```bash
curl -X POST [https://accounts.spotify.com/api/token](https://accounts.spotify.com/api/token) \
     -u "CLIENT_ID:CLIENT_SECRET" \
     -d "grant_type=authorization_code" \
     -d "code=THE_CODE_COPIED_FROM_URL" \
     -d "redirect_uri=http://127.0.0.1:8888/callback"

```
grab the `refresh_token` from the json output. update the secret restart the service
