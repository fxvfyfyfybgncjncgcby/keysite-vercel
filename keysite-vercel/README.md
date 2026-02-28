# 🔑 Key System — Vercel + Supabase

## Structure
```
keysite-vercel/
├── api/
│   ├── _supabase.js   ← client Supabase partagé
│   ├── getlink.js     ← génère le lien Linkvertise
│   ├── complete.js    ← génère la key après Linkvertise
│   └── checkkey.js    ← vérifie une key depuis Lua
├── public/
│   ├── index.html     ← page principale
│   └── complete.html  ← page affichant la key
├── script.lua         ← ton script Roblox modifié
├── supabase.sql       ← tables à créer
├── package.json
└── vercel.json
```

---

## ÉTAPE 1 — Supabase (base de données gratuite)

1. Va sur https://supabase.com → **New project**
2. Donne un nom, un mot de passe, choisis une région → **Create project**
3. Une fois créé : **SQL Editor** (menu gauche) → **New query**
4. Colle tout le contenu de `supabase.sql` → **Run**
5. Récupère tes clés :
   - **Settings** → **API**
   - Copie **Project URL** → c'est ton `SUPABASE_URL`
   - Copie **service_role (secret)** → c'est ton `SUPABASE_SERVICE_KEY`

---

## ÉTAPE 2 — Vercel (hébergement gratuit)

1. Va sur https://vercel.com → connecte-toi avec GitHub
2. **Add New Project** → **Import Git Repository**
   - Crée un repo GitHub, push les fichiers dedans
   - OU utilise **Vercel CLI** (voir ci-dessous)
3. Dans les **Environment Variables** du projet Vercel, ajoute :
   ```
   SUPABASE_URL        = https://xxxx.supabase.co
   SUPABASE_SERVICE_KEY = eyJhb...
   SITE_URL            = https://ton-projet.vercel.app
   LINKVERTISE_USER_ID = 123456
   ```
4. **Deploy** → Vercel te donne une URL comme `ton-projet.vercel.app`

### Déployer avec Vercel CLI (plus simple depuis VS Code)
```bash
npm install -g vercel
cd keysite-vercel
npm install
vercel
# Suit les instructions, connecte-toi
# Ajoute les variables d'env quand demandé
```

---

## ÉTAPE 3 — Linkvertise

1. Va sur https://linkvertise.com → crée un compte
2. **Dashboard** → note ton **User ID** (dans l'URL ou les settings)
3. Mets cet ID dans la variable `LINKVERTISE_USER_ID` sur Vercel

---

## ÉTAPE 4 — Modifier ton script Lua

Dans `script.lua`, change juste cette ligne :
```lua
local SITE_URL = "https://TON-SITE.vercel.app"
```

---

## ÉTAPE 5 — Test

1. Va sur `https://ton-site.vercel.app` → tu vois la page key
2. Clique **Obtenir ma Key** → ouvre Linkvertise
3. Complète Linkvertise → redirigé vers `/complete?token=...`
4. Ta key s'affiche (format `XXXX-XXXX-XXXX-XXXX`)
5. Dans Roblox, colle la key dans l'UI → ✓ validée !

---

## Flow complet

```
Joueur ouvre le script
        ↓
UI s'affiche dans Roblox
        ↓
Clique "Get Key" → SITE_URL copié
        ↓
Va sur ton site → clique le bouton
        ↓
Lien Linkvertise généré avec token unique
        ↓
Complète Linkvertise (10 sec)
        ↓
Redirigé vers /complete?token=xxx
        ↓
API vérifie le token → génère XXXX-XXXX-XXXX-XXXX
        ↓
Joueur copie la key → la colle dans l'UI Roblox
        ↓
Script appelle /api/checkkey?key=...&hwid=...
        ↓
✅ Key valide → script démarre !
```

---

## API Reference

| Endpoint | Description |
|----------|-------------|
| `GET /api/getlink` | Génère le lien Linkvertise |
| `GET /api/complete?token=xxx` | Valide le token et génère la key |
| `GET /api/checkkey?key=xxx&hwid=xxx` | Vérifie une key depuis Lua |
