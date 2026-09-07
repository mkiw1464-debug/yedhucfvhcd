# FF External

Free Fire & Free Fire Max cheat injector for iOS.  
Built on Flutter with native Swift exploit layer (file access via MCM + sandbox escape).

---

## Setup

### 1. GitHub Repo — cheat files

Create your cheat file repo at: `https://github.com/mkiw1464-debug/kntollshahhaha/`

Folder structure:
```
/FreeFire/
    Aimbody/character.bundle
    Aimneck/character_neck.bundle
    Aimdrag/aim_drag.bundle
    Magic Bullet/projectile.bundle
    Antena/antenna.bundle
    Hologram/hologram.bundle

/FreeFireMax/
    (same structure)
```

If a file is missing from the repo → that feature shows **Unavailable** automatically.

---

### 2. Build IPA via GitHub Actions

Push this repo to GitHub. Actions will:

1. Set up Flutter 3.22
2. Run `flutter pub get` + `gen-l10n`
3. `pod install`
4. `flutter build ios --release --no-codesign`
5. Package as `FFExternal.ipa`
6. Upload as artifact + create a release

Download `FFExternal.ipa` from **Actions → Artifacts** or **Releases**.

---

### 3. License API

The app hits: `https://ffexxxx.vercel.app/api/licenses/validate`

Expected response:
```json
{
  "valid": true,
  "status": "active",
  "expires_at": "2026-10-07T15:00:00.000Z",
  "hwid": "device-id"
}
```

---

## Supported Languages

- 🇺🇸 English
- 🇮🇩 Bahasa Indonesia  
- 🇧🇷 Português (Brasil)
- 🇻🇳 Tiếng Việt
- 🇹🇼 繁體中文 (台灣)

---

## Inject Flow

1. App resolves FF/FFMax container via MCM + sandbox escape
2. Backs up original asset file to `Documents/FFExternal_Backups/`
3. Downloads cheat bundle from GitHub
4. Replaces target file via `FileReplacementService` (atomic rename)
5. **Restore** puts the original back and clears backup

---

## Telegram

https://t.me/ffexternal
"# yedhucfvhcd" 
