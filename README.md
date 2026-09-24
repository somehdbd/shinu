# Cashbook: setup with Supabase and Vercel

## 1. Create the database (Supabase)
1. Go to https://supabase.com, sign up, and click **New project**. Pick a name, a database password (save it somewhere) and the region closest to you (e.g. Mumbai).
2. When the project is ready, open **SQL Editor**, click **New query**, paste everything from `supabase-setup.sql`, and click **Run**. You should see "Success. No rows returned".
3. Open **Project Settings → API** (or **Connect / API Keys**) and copy:
   - **Project URL** (looks like `https://abcd1234.supabase.co`)
   - **anon public** key (a long text starting with `eyJ...` or `sb_publishable_...`)
   Never use the **service_role** / secret key in this app.

## 2. Add your keys to the app
Open `index.html` in a text editor (Notepad is fine), find this near the top, and paste your two values:

```
SUPABASE_URL: "PASTE_PROJECT_URL_HERE",
SUPABASE_ANON_KEY: "PASTE_ANON_PUBLIC_KEY_HERE"
```

Keep the quotes. Save the file.

## 3. Put it online (Vercel)
1. Create a free account at https://github.com, click **New repository**, name it `cashbook`, and create it.
2. On the new repository page, click **uploading an existing file**. Select **all** these files at once and drop them in: `index.html`, `manifest.webmanifest`, `sw.js`, `vercel.json`, `icon-192.png`, `icon-512.png`, `maskable-512.png`, `apple-touch-icon.png`, `favicon-64.png`. Click **Commit changes**. (`README.md` and `supabase-setup.sql` are optional.) All files sit at the top level; there are no folders.
3. Go to https://vercel.com, sign up with your GitHub account, click **Add New → Project**, pick the `cashbook` repository and click **Deploy**. Leave all settings as they are.
4. After about a minute you get an address like `cashbook-xyz.vercel.app`.

Later changes: edit or re-upload `index.html` on GitHub, and Vercel updates the site on its own.

## 4. Tell Supabase your site address
In Supabase, open **Authentication → URL Configuration**:
- **Site URL**: your address, e.g. `https://cashbook-xyz.vercel.app` (or your own domain once it's connected)
- **Redirect URLs**: add the same address(es), including your own domain

Without this, email confirmation and password-reset links will point to the wrong place.

## 5. Use your own domain (optional)
In Vercel, open your project → **Settings → Domains**, type your domain (e.g. `cashbook.yourdomain.com`) and click **Add**. Vercel shows a DNS record to add at the company where you bought the domain (GoDaddy, Namecheap, Hostinger…). Copy it exactly as shown. It usually works within an hour, with HTTPS included. Then add this domain in Supabase step 4 too.

## 6. First sign-in
Open your site, choose **Create account**, enter your email and a password, and click the confirmation link Supabase emails you. Then sign in.

To move your old entries: in the old Cashbook click **Export CSV**, then in the new one click **Import CSV**.

## 7. Install it like an app
- **Android (Chrome):** open your site and tap **Install app** in Cashbook, or Chrome's menu (⋮) → **Install app** / **Add to Home screen**.
- **iPhone / iPad:** open the site in **Safari**, tap **Share** (□↑) → **Add to Home Screen**.
- **Windows / Mac (Chrome or Edge):** click **Install app** in Cashbook, or the install icon at the right end of the address bar.

It then opens in its own window with the Cashbook icon. Long-pressing the icon on Android shows an **Add entry** shortcut.
Without internet the app still opens and shows what was last loaded, but new entries need a connection.

After you upload a new version, close and reopen the installed app once or twice to pick it up.

## Good to know
- **Only you, or anyone?** By default anyone who finds the site can create an account. Each account sees only its own entries. To keep it just for you, go to Supabase → **Authentication → Sign In / Providers** and turn off **Allow new users to sign up**, after you've created your own account.
- **Free plan pause:** Supabase pauses free projects after about a week with no activity. Your data is kept. Open the Supabase dashboard and click **Restore project** to wake it.
- **Email limits:** Supabase's built-in email sender only sends a few emails per hour. That's fine for personal use. For many users, connect your own email service under Authentication → SMTP settings.
- **Backups:** use **Export CSV** now and then.
