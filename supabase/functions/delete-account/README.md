# delete-account

Deletes the authenticated user (`Authorization: Bearer <access_token>`) after `confirm: true` in the JSON body.

Deploy:

```bash
supabase functions deploy delete-account --no-verify-jwt
```

The Flutter app calls this function with `{ "confirm": true }`.
