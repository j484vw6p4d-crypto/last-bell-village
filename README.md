# last-bell-village

This repo is for the **Test 1 village map** in Roblox Studio.

The village is **not Lua**. It is parts + terrain saved inside the Test 1 place.
`last-bell-docks` never contained village source. Its first commit was already the docks rebuild. Connecting that repo to Test 1 runs Boot, which deletes the village on Play.

## Use this repo with Test 1

```powershell
cd $HOME\Documents
git clone https://github.com/j484vw6p4d-crypto/last-bell-village.git
cd last-bell-village
rojo serve
```

Studio: open **Test 1** only → Rojo Connect → Play.

This project does **not** clear Terrain and does **not** destroy Workspace. The village should stay.

## Docks Last Bell stays here

https://github.com/j484vw6p4d-crypto/last-bell-docks

Do not `rojo serve` docks while Test 1 is open if you want the village.
