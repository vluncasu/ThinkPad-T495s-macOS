# ThinkPad T495s Hackintosh - macOS Ventura | AMD Ryzen 7 PRO 3700U + Radeon Vega 10

**EFI OpenCore pentru Lenovo ThinkPad T495s (20QK) cu macOS Ventura pe AMD Ryzen și accelerare GPU Radeon Vega 10 (mobile) prin NootedRed.**

Configurație OpenCore specifică hardware-ului și jurnal tehnic complet pentru Lenovo ThinkPad T495s type 20QK, AMD Ryzen 7 PRO 3700U și Radeon Vega 10 (Picasso mobile iGPU). Sistemul principal documentat este macOS Ventura 13.7.8, build 22H730.

Documentația tehnică de referință este în engleză, în [`README.md`](README.md) și directorul [`Docs/`](Docs/README.md). Acest fișier rezumă în română starea reală a proiectului fără a transforma simpla prezență a unui kext într-o afirmație de funcționare.

Valorile SMBIOS din copia publică sunt intenționat fictive. Ele trebuie înlocuite înainte de folosirea EFI-ului public.

## Starea actuală

Există două probleme majore de platformă, în această ordine:

1. **Stabilitatea accelerației grafice.** Vega 10 are framebuffer, accelerator și Metal prin NootedRed, iar Geekbench Metal rulează. Totuși, Chrome cu accelerare hardware a produs artefacte, blocarea canalului GFX AMD și freeze complet al sistemului. Chrome este confirmat de utilizator ca funcțional când accelerarea hardware este dezactivată. Aceasta este o soluție de evitare, nu un fix al driverului.
2. **Sleep/wake nativ.** macOS poate intra în sleep și există wake-uri reușite în loguri, dar secvența nu este repetabilă și un test controlat a intrat în sleep fără un wake finalizat înainte de restartul forțat. Închiderea/deschiderea normală a capacului nu poate fi clasificată încă drept funcție rezolvată.

Acestea sunt singurele două probleme clasificate în documentație drept blocaje majore de platformă. Celelalte limitări sunt locale unui subsistem.

## Ce funcționează și ce nu este încă validat

| Subsistem | Stare | Observație |
|---|---|---|
| Boot OpenCore | Observat funcțional | EFI-ul pornește Ventura pe T495s-ul țintă. |
| macOS Ventura 13.7.8 | Observat funcțional | Build 22H730 este prezent în benchmark-uri și diagnostice. |
| Ryzen 7 PRO 3700U | Observat funcțional | 4 nuclee / 8 fire; Cinebench R23 multi-core finalizat. |
| Patch-uri AMD pentru XNU | Observat funcțional pentru boot/userspace | Setul activ permite rularea macOS; nu trebuie confundat cu stabilitatea GPU. |
| Vega 10 framebuffer | Observat funcțional | Panoul intern rulează 1920x1080 la 60 Hz. |
| Metal | Observat funcțional | Geekbench Metal a finalizat două rulări documentate. |
| Stabilitate GPU accelerat | Nerezolvat | Chrome accelerat poate bloca GFX și întregul sistem. |
| Chrome fără GPU | Confirmat de utilizator | Funcționează cu accelerarea hardware dezactivată. |
| Taste/slider brightness | Observat funcțional ca interfață | macOS vede și poate modifica proprietatea de brightness. |
| PWM fizic continuu | Nerezolvat | Panoul răspunde practic prin aproximativ două niveluri utile. |
| Overlay brightness v17 | Implementat, necesită revalidare | Dimming vizual AppKit; nu este PWM fizic. |
| Tastatură internă | Observat funcțional | Calea PS/2 este activă. |
| Touchpad Elan PS/2 | Confirmat de utilizator | VoodooPS2 + tuning Elantech. |
| Wi-Fi AX200 după instalare | Confirmat de utilizator | AirportItlwm este activ în profilul normal. |
| Wi-Fi în installer | Problemă cunoscută | Poate lipsi sau destabiliza/crăpa installerul; există profil fără Wi-Fi. |
| Bluetooth | Enumerat/configurat | Dispozitivul Intel și stack-ul de firmware sunt prezente; fiabilitatea pe termen lung nu este declarată fără test dedicat. |
| Audio ALC257 | Configurat | AppleALC + `alcid=97`; matricea completă speaker/headphone nu este arhivată public. |
| Startup chime | Configurat | AudioDxe + `PlayChime=Enabled`; confirmarea auditivă nu este arhivată. |
| Ethernet | Configurat | RealtekRTL8111 inclus; nu există benchmark public de throughput. |
| NVMe | Observat funcțional | Sistemul instalat pornește de pe NVMe; NVMeFix inclus. |
| USB map | Observat pentru dispozitivele enumerate | Hub intern, cameră, Bluetooth și stocare USB apar în diagnostice. |
| Cameră integrată | Enumerată | `13D3:5406`; validarea într-o aplicație nu este arhivată. |
| Battery/EC | Configurat și încărcat | SMCBatteryManager + ECEnabler. |
| SD reader | Configurat | EmeraldSDHC inclus; citire/scriere card nu este arhivată. |
| Sleep/wake nativ | Nerezolvat | A doua problemă majoră. |
| Sleep nativ la capac | Nerezolvat | Workaround-ul istoric de continuitate nu este sleep. |
| Touchscreen | Experimental / neenumerat | Controller Windows-side `1A86:E5E3`; macOS nu îl vede în IOUSB/IOHID. |

Starea formală completă este în [`Docs/STATUS.md`](Docs/STATUS.md) și [`Docs/TEST-MATRIX.md`](Docs/TEST-MATRIX.md).

## Hardware țintă

```text
Model: Lenovo ThinkPad T495s
Type: 20QK
BIOS: R13ET56W 1.30
CPU: AMD Ryzen 7 PRO 3700U, 4C/8T
GPU: AMD Radeon Vega 10, PCI 1002:15D8
RAM: 16 GB DDR4-2400
Panou intern: InfoVision IVO057D / R140NWF5 RG, 1920x1080 60 Hz
Audio: Realtek ALC257
Wi-Fi: Intel AX200
Bluetooth: Intel USB 8087:0029
Ethernet: Realtek RTL8111 family
NVMe: Crucial / Micron P3 Plus family
Touchpad: Elan PS/2 v4
Touchscreen Windows-side: 1A86:E5E3 / USB2IIC_CTP_CONTROL
Hub USB intern: Genesys Logic 05E3:0610
Cameră: AzureWave 13D3:5406
SMBIOS: MacBookPro16,3
macOS: Ventura 13.7.8 / 22H730
```

## Stratul de pre-boot

Laptopul este un sistem Lenovo OEM proiectat în jurul unui mediu Windows. Firmware-ul ACPI ia decizii în funcție de interogări ale tipului `_OSI(...)`.

Configurația folosește:

```text
SSDT-XOSI.aml
ACPI binary rename: _OSI -> XOSI
```

Scopul este interpunerea asupra răspunsurilor ACPI privind identitatea/capabilitățile sistemului de operare, astfel încât anumite ramuri Lenovo gândite pentru Windows să poată fi expuse într-o formă compatibilă când sistemul real este macOS.

Aceasta poate fi descrisă corect drept **emulare a răspunsurilor ACPI OS-interface**. Nu este emulare Windows în sensul executării unui kernel Windows și nu transformă macOS în Windows.

Separat, OpenCore prezintă către macOS o identitate Apple `MacBookPro16,3`. Cele două mecanisme au destinatari diferiți:

```text
Lenovo ACPI vede răspunsuri de compatibilitate controlate prin XOSI.
macOS vede identitatea Apple prezentată prin PlatformInfo.
```

Documentație: [`Docs/PREBOOT-COMPATIBILITY.md`](Docs/PREBOOT-COMPATIBILITY.md).

## Compatibilitatea CPU AMD

macOS nu pornește nativ un Ryzen 7 PRO 3700U folosind aceeași cale ca un Mac Intel. EFI-ul conține un set de patch-uri de kernel XNU pentru CPUID, topologie, cache, MSR, familia CPU, timekeeping și alte ipoteze Intel din kernel.

Snapshot-ul documentat are:

```text
22 kernel patch entries
20 enabled
2 disabled
```

Inventarul exact este în [`Docs/KERNEL-PATCHES.md`](Docs/KERNEL-PATCHES.md).

Acest strat CPU este diferit de NootedRed. Faptul că macOS pornește corect pe CPU nu înseamnă că GPU-ul este stabil.

## Vega 10 și problema Chrome

NootedRed 0.9.0 + Lilu 1.7.2 expun calea AMD Vega 10 suficient pentru:

```text
framebuffer intern
Metal
Geekbench Metal
accelerare grafică în aplicații
```

Dar un raport real `gpuRestart` a capturat:

```text
Event: GPU Reset
Application: Google Chrome Helper
Graphics Hardware: AMD Radeon Vega 10
SubmitContext: Metal
IOAcceleratorFamily2: hardware error
AMDRadeonX5000: channel 0 GFX event timeout
AMDRadeonX5000: channel 0 GFX is hung
```

Au existat și panic-uri asociate cu procesor nereceptiv/TLB flush timeout în timpul diagnosticului AMD graphics. Documentația nu declară automat aceste panic-uri drept o a treia problemă independentă; ele sunt tratate ca observații secundare ale aceleiași zone grafice până la o reproducere separată.

Workaround-ul actual pentru Chrome este dezactivarea accelerării grafice. Scriptul:

```text
Tools/Chrome/Launch-Safe.command
```

pornește Chrome cu:

```text
--disable-gpu
--disable-gpu-compositing
--disable-accelerated-video-decode
```

Aceasta nu repară NootedRed sau AMDRadeonX5000. Elimină workload-ul care reproduce problema în Chrome.

Documentație: [`Docs/GRAPHICS.md`](Docs/GRAPHICS.md).

## Brightness: ce este real și ce este emulat

Controlul brightness are două niveluri distincte.

### 1. Control plane macOS

Proiectul construiește o cale prin:

```text
Fn/EC/ACPI
NBCF forwarding patch
BrightnessKeys
SSDT-PNLF
AMDBacklight=1 / NootedRed
IODisplayConnect brightness property
macOS brightness UI
```

Această cale face ca macOS să aibă **permisiunea/interfața logică de control**: sliderul și tastele modifică o valoare de brightness recunoscută de sistem.

### 2. Răspunsul fizic al panoului

Panoul nu urmărește valoarea macOS ca un backlight Apple cu multe trepte PWM. În testele efectuate, răspunsul fizic util este aproximativ binar: foarte luminos și puțin mai redus.

Prin urmare:

```text
control logic macOS: prezent
control PWM fizic continuu: absent/nerezolvat
```

### Istoric

- v9-v12 au construit calea PNLF/BrightnessKeys/NBCF/NootedRed.
- v13 a încercat un patch binar de scalare PWM în NootedRed; nu a rezolvat intervalul fizic și a fost retras.
- v15/v16 au adăugat dimming vizual prin scriere repetată a curbelor gamma; efectul vizual a existat, dar bridge-ul a fost izolat ca sursă de instabilitate/freeze și a fost eliminat.
- v17 folosește o fereastră AppKit neagră, click-through, cu alpha variabil pentru a completa vizual intervalul sub pragul hardware. Nu creează trepte PWM noi și nu economisește proporțional energie de backlight.

La migrare/start/wake, v17 poate apela `CGDisplayRestoreColorSyncSettings()` pentru a elimina starea lăsată de vechiul experiment gamma. Nu folosește continuu `CGSetDisplayTransferByFormula`.

Overlay-ul v17 este documentat drept **implementat, în așteptarea revalidării susținute**, nu drept soluție nativă finală.

Documentație: [`Docs/BRIGHTNESS.md`](Docs/BRIGHTNESS.md).

## Touchpad

Touchpad-ul real este Elan PS/2, nu un device I2C utilizat prin VoodooI2C în configurația curentă.

Calea activă:

```text
VoodooPS2Controller
VoodooInput
VoodooPS2Keyboard
VoodooPS2Trackpad
```

Tuning relevant:

```text
ForceTouchMode = 0
QuietTimeAfterTyping = 0
WakeDelay = 100
UseHighRate = true
MouseSampleRate = 200
ProcessUSBMouseStopsTrackpad = false
ProcessBluetoothMouseStopsTrackpad = false
USBMouseStopsTrackpad = 0
ScrollResolution = 400
TrackpointMultiplierX = 120
TrackpointMultiplierY = 120
```

Installerul scrie și preferințele pentru tap-to-click și secondary click.

Documentație: [`Docs/INPUT.md`](Docs/INPUT.md).

## Touchscreen experimental

Windows identifică controllerul ca:

```text
USB2IIC_CTP_CONTROL
VID 1A86
PID E5E3
```

În macOS, probele au găsit hub-ul intern Genesys, camera și Bluetooth, dar **nu au enumerat controllerul touchscreen** în IOUSB sau IOHID.

Din acest motiv, configurația de producție nu forțează un port USB nou pentru touchscreen și nu instalează implicit bridge-ul experimental.

Directorul:

```text
Experimental/Touchscreen/
```

conține un probe și un bridge userspace care, numai după enumerare, poate citi coordonate HID, normaliza X/Y pe panoul intern și sintetiza evenimente pointer. În starea actuală bridge-ul este blocat de lipsa device-ului fizic în arborele macOS.

Documentație: [`Docs/TOUCHSCREEN.md`](Docs/TOUCHSCREEN.md).

## Sleep/wake

Un test controlat a avut:

```text
03:28:14  Entering Sleep state due to 'Software Sleep'
...        no completed Wake recorded
03:29:51  new boot context after forced restart
```

Există însă și un control anterior:

```text
00:30:55  Sleep
00:30:59  DarkWake due to HID Activity
00:31:00  DarkWake to FullWake
00:31:00  WakeTime: 0.541 s
```

Concluzia corectă este:

```text
sleep entry: demonstrat
unele wake-uri: demonstrate
sleep/resume repetabil: nedemonstrat
lid close/open nativ: nerezolvat
```

Workaround-ul istoric `Tools/Power/Enable-Continuity.command` dezactivează intenționat suspendarea și stinge doar display-ul/lock screen la capac. Laptopul rămâne alimentat. Acesta nu este instalat de installerul v17 implicit și nu trebuie numit sleep.

Documentație: [`Docs/POWER-SLEEP.md`](Docs/POWER-SLEEP.md).

## Wi-Fi în timpul instalării

Intel AX200 este confirmat ca funcțional după instalarea Ventura, dar AirportItlwm poate fi indisponibil sau poate destabiliza/crăpa mediul macOS Installer pe această configurație.

Este inclus:

```text
EFI/OC/Config-Profiles/config-install-no-wifi.plist
```

Acest profil trebuie să difere de profilul public normal numai prin:

```text
AirportItlwm.kext -> Enabled = false
```

După instalare se revine la profilul normal.

Documentație: [`Docs/INSTALLATION.md`](Docs/INSTALLATION.md), [`Docs/NETWORKING.md`](Docs/NETWORKING.md).

## Benchmark-uri documentate

### Cinebench R23

```text
CPU Multi Core: 3141 pts
CPU: AMD Ryzen 7 PRO 3700U
4 cores / 8 threads
macOS 13.7.8 / 22H730
```

### Geekbench Metal

```text
Run A: 11179
Run B: 5164
```

Diferența dintre rulări este păstrată ca parte a istoricului, nu ascunsă sau mediată într-o singură cifră.

### Geekbench CPU

Nu a fost furnizat un rezultat standalone Geekbench CPU în materialele analizate. Documentația îl marchează `NOT-TESTED` în loc să inventeze un scor.

Detalii și imagini: [`Docs/BENCHMARKS.md`](Docs/BENCHMARKS.md).

## Documentație principală

- [`Docs/README.md`](Docs/README.md) - indexul documentației.
- [`Docs/STATUS.md`](Docs/STATUS.md) - starea exactă a fiecărui subsistem.
- [`Docs/TEST-MATRIX.md`](Docs/TEST-MATRIX.md) - matricea testelor și a dovezilor.
- [`Docs/HARDWARE.md`](Docs/HARDWARE.md) - inventar hardware.
- [`Docs/ARCHITECTURE.md`](Docs/ARCHITECTURE.md) - arhitectura pe straturi.
- [`Docs/PREBOOT-COMPATIBILITY.md`](Docs/PREBOOT-COMPATIBILITY.md) - XOSI și pre-boot.
- [`Docs/CONFIGURATION.md`](Docs/CONFIGURATION.md) - configurația OpenCore exactă.
- [`Docs/KERNEL-PATCHES.md`](Docs/KERNEL-PATCHES.md) - patch-urile AMD XNU.
- [`Docs/GRAPHICS.md`](Docs/GRAPHICS.md) - NootedRed, Chrome, GPU reset, panic-uri.
- [`Docs/BRIGHTNESS.md`](Docs/BRIGHTNESS.md) - control plane, PWM, gamma, overlay v17.
- [`Docs/INPUT.md`](Docs/INPUT.md) - tastatură și touchpad.
- [`Docs/TOUCHSCREEN.md`](Docs/TOUCHSCREEN.md) - experiment touchscreen.
- [`Docs/POWER-SLEEP.md`](Docs/POWER-SLEEP.md) - sleep/wake și lid continuity.
- [`Docs/NETWORKING.md`](Docs/NETWORKING.md) - Wi-Fi/Bluetooth/Ethernet.
- [`Docs/STORAGE-USB.md`](Docs/STORAGE-USB.md) - USB, NVMe, cameră, SD.
- [`Docs/AUDIO.md`](Docs/AUDIO.md) - AppleALC și chime UEFI.
- [`Docs/BENCHMARKS.md`](Docs/BENCHMARKS.md) - benchmark-uri.
- [`Docs/DEVELOPMENT-HISTORY.md`](Docs/DEVELOPMENT-HISTORY.md) - istoric v2-v17.
- [`Docs/KNOWN-ISSUES.md`](Docs/KNOWN-ISSUES.md) - probleme cunoscute.
- [`Docs/METHODOLOGY.md`](Docs/METHODOLOGY.md) - metodologia de validare.
- [`Docs/EVIDENCE.md`](Docs/EVIDENCE.md) - standardul de dovezi.
- [`Docs/SECURITY.md`](Docs/SECURITY.md) - postura de securitate/publicare.
- [`Docs/GLOSSARY.md`](Docs/GLOSSARY.md) - terminologie.

## Regula de publicare

Copia GitHub conține placeholder-e:

```text
SystemSerialNumber = C02DEMO00000
MLB                = C02DEMO0000000000
SystemUUID         = 00000000-0000-0000-0000-000000000000
ROM                = 00 00 00 00 00 00
```

Ele nu trebuie folosite ca identitate Apple reală. Generează valori proprii înainte de boot.

Validarea repository-ului se poate rula cu:

```bash
python3 Scripts/validate_release.py
```

Acest validator verifică integritatea documentației/configurației publice. Nu poate transforma un subsistem nerezolvat într-unul funcțional fără test pe hardware.
