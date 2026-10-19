# Third-party components and notices

Trundle includes the components below. Their licenses apply to their respective
files and are not replaced by Trundle's MIT or CC BY 4.0 licenses. Keep the
source-file copyright and attribution notices when redistributing the sources.

This inventory describes the vendored files in this repository, including local
compatibility fixes. Versions are taken from the included sources where
available; exact upstream commit IDs were not recorded for these snapshots.

## Components

| Component | Included version | Location | License and notices |
| --- | --- | --- | --- |
| cocos2d for iPhone | 2.1.0 | `External Source/cocos2d/` | MIT, with the embedded exceptions below. Copyright Ricardo Quesada, Zynga Inc., and the contributors named in each file. [License](External%20Source/LICENSE_cocos2d.txt). [Upstream](https://github.com/cocos2d/cocos2d-iphone). |
| Chipmunk Physics | 6.1.4 | `External Source/external/Chipmunk/` | MIT. Copyright Scott Lembcke and Howling Moon Software; retain per-file notices. [License](External%20Source/external/Chipmunk/LICENSE.txt). [Upstream](https://github.com/slembcke/Chipmunk2D). |
| CocosDenshion | Snapshot bundled with cocos2d | `External Source/CocosDenshion/` | MIT. Copyright Steve Oldmeadow. Apple sample-code exceptions apply to OpenAL helpers. [License](External%20Source/LICENSE_CocosDenshion.txt). |
| Kazmath | Vendored snapshot; no package version recorded | `External Source/kazmath/` | BSD 2-Clause. Copyright Luke Benstead and contributors. NEON helper exceptions below. [License](External%20Source/LICENSE_Kazmath.txt). [Upstream](https://github.com/Kazade/kazmath). |
| SpaceManager | 0.2.2 version macro; modified for this game | `Support/SpaceManager/` | Original Mobile Bros./Robert Blackwood code is covered by the project's [MIT license](LICENSE-MIT.txt). Embedded TinyXML and pulley-joint code retain the notices below. |
| TinyXML | 2.6.1 | `Support/SpaceManager/cpSpaceSerializer/tinyxml/` | zlib-style license. Copyright Lee Thomason and contributors; exact notice in [`tinyxml.h`](Support/SpaceManager/cpSpaceSerializer/tinyxml/tinyxml.h). [Upstream](https://sourceforge.net/projects/tinyxml/). |

## Embedded exceptions and supporting code

The exact copyright and license notices from these files, and from the remaining
vendored source files, are collected in
[licenses/THIRD_PARTY_LICENSES.txt](licenses/THIRD_PARTY_LICENSES.txt).
The notices also remain in their original source files.

| Code | Copyright / attribution | Terms |
| --- | --- | --- |
| Apple-derived texture, font, GL renderer, and OpenAL helpers in cocos2d and CocosDenshion | Apple Inc.; see each file for the applicable year and notice | Apple sample-code licenses; the full notices are preserved in the source and collected notice file. |
| `External Source/cocos2d/Support/uthash.h` and `utlist.h` | Troy D. Hanson | BSD-style license as printed in each header. |
| `External Source/kazmath/src/neon_matrix_impl.c` and matching header | Justin Saunders | zlib-style license as printed in those files. The ARM32-only compatibility change is marked in the source. |
| `Support/SpaceManager/cpExtras/cpPulleyJoint.c` and `.h` | Robert Blackwood and Erin Catto | MIT; retain both copyright notices. |
| `External Source/cocos2d/Support/base64.c` and `.h` | Public-domain code, modified for cocos2d | The included headers explicitly identify this code as public domain. |
| `External Source/cocos2d/Support/TGAlib.*` | Sources credited to Lighthouse3D | Included as part of the cocos2d snapshot; retain its source attribution and the cocos2d license. |
| `External Source/cocos2d/Support/NSThread+performBlock.*` | The source credits the linked Stack Overflow answer as the idea | Included as part of the cocos2d snapshot; retain that attribution and the cocos2d license. |
| `External Source/cocos2d/Support/ZipUtils.*` | Credits zlib example code and The Mana World for implementation ideas | Retain the existing source credits and cocos2d license. The zlib implementation itself is linked from the platform SDK, not vendored here. |
| `External Source/cocos2d/images/fire.png` | cocos2d distribution asset | Covered by the accompanying cocos2d distribution license; excluded from Trundle's original-artwork CC BY 4.0 grant. |

Apple SDK frameworks and the system zlib library are linked dependencies. Their
implementations are not distributed in this repository.

## Removed legacy components

The iSimulate archive, cocoslive, its unused TouchJSON dependency, FontLabel,
StoreKit purchase code, reachability helpers, RadialMenu, and PhysicsEditor
adapter are not included in this release. The game does not depend on those
components or their former services.
