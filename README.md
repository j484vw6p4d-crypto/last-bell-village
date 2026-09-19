# last-bell-village

Test 1 village map. **Do not connect last-bell-docks** to Test 1.

V2 builds **Millbrook Square** on Play: inn, chapel, cottages, smithy, market.
It only removes the middle maintenance blockout. Terrain / mountains stay. No Terrain:Clear.

```powershell
cd $HOME\Documents\last-bell-village
git pull
rokit install
rojo serve
```

Studio: open **Test 1** → Rojo Connect → Play.
HUD should say **TEST 1 · MILLBROOK V2**.

Docks repo (leave alone): https://github.com/j484vw6p4d-crypto/last-bell-docks
