# Rebel CAD's OpenCascade build

`rebel_occt.js` / `rebel_occt.wasm` are Open CASCADE Technology 8.0.1 compiled to WebAssembly, with JavaScript
bindings for the classes listed in `custom_build.yml`. The kernel loads them from here (src/cad/kernel/occ.ts, the
browser workers), as a separate file, unmodified after the build.

## What it is

- OCCT V8_0_1, commit `b8f597c677811d1f9f4d8a97f5ae2825c0353a42` (https://github.com/Open-Cascade-SAS/OCCT),
  LGPL-2.1 with the OCCT exception. Its source is at that commit; nothing in it is changed.
- Compiled and bound by opencascade.js (taucad's fork, https://github.com/taucad/opencascade.js, commit
  `ebd263f15337b440b391492af073662707e86482`), Emscripten 5.0.1, single-threaded, -O3, wasm exceptions, SIMD.
- The class list is replicad-opencascadejs 1.1.0's (https://github.com/sgenoud/replicad, packages/replicad-opencascadejs,
  commit `e4b05f67dc`), which the kernel used before, plus:
  BRepAlgoAPI_Defeaturing, BRepPrimAPI_MakeCone, BRepPrimAPI_MakeWedge, gp_Cone, gp_Torus, Geom_ToroidalSurface,
  BRepTools_WireExplorer, IntCurvesFace_ShapeIntersector, BRepFeat_SplitShape, BRepBuilderAPI_MakePolygon,
  BRep_Builder, BRepTools_History, BRepTools_ReShape, BRepClass3d_SolidClassifier, ShapeFix_Shape,
  ShapeAnalysis_FreeBounds, BRepLProp_SLProps, GeomLProp_SLProps, Law_Constant, TopExp,
  TopTools_IndexedDataMapOfShapeListOfShape, STEPCAFControl_Reader; and (1 Nov, second build) gp_Lin,
  BRepClass3d_SClassifier, BRepOffset_Status; and (20 Nov, third build) BRepBuilderAPI_GTransform (non-uniform scale
  and the ellipsoid, feedback F37; its gp_GTrsf and BRepBuilderAPI_ModifyShape were bound already).
- `wrappers/*.cpp` are replicad's helpers (mesh and edge extraction, hashing, B-rep I/O), unchanged, and Rebel CAD's
  own `wrappers/face-offset.cpp` (RebelFaceOffset: BRepOffset_MakeOffset with an offset per face, for move face on
  curved faces; the class itself has no compiled binding in the image, nor has DESTEP_Parameters).

## Building it again

The image holds OCCT already compiled; the build binds the listed classes and links (about two minutes):

```
docker pull ghcr.io/taucad/opencascade.js@sha256:deb9be8470038652c060b47f2d2e7e2e46d899bb896ecabb007bf60307ee2d54
cd <a copy of this folder>
docker run --rm --network none -v "$(pwd):/src" -u "$(id -u):$(id -g)" \
  ghcr.io/taucad/opencascade.js@sha256:deb9be8470038652c060b47f2d2e7e2e46d899bb896ecabb007bf60307ee2d54 \
  link custom_build.yml
```

It writes `rebel_occt.js`, `.wasm`, `.d.ts` and a provenance file. Add a class to `custom_build.yml` (`- symbol:`)
and build again to bind it.

After a build, bring `notice.json` up to date: the sha256 of the new `rebel_occt.wasm` and `rebel_occt.js`, and
whatever of the versions and commits changed. The app's open source notices (`licenses.txt`, written by
`npm run build:cad`: src/cad/server/notices.ts) are made from it, and the licence check (`npm run licences:cad`) and
the unit tests fail while the files are not the ones it is about.

## Licence

`notice.json` says what the notices print about this build. `LICENSE_LGPL_21.txt` and `OCCT_LGPL_EXCEPTION.txt` are
OCCT's own files at the commit above, unchanged; the notices carry them in full.

## Checked

- The same recipe with replicad's own list gave a `.d.ts` and `.js` identical to replicad-opencascadejs 1.1.0's, and
  all 42 saved projects regenerated the same with it (every feature's status, every part's solids, volume, face and
  edge names).
- The first build (1 Nov 2026): wasm sha256 `e4d8438f2fe542a40d7779833cdb68861f6130cdc3db2ddca2c96c2fc4b332de`,
  23 546 310 bytes (replicad's: 22 980 267).
- The second build (1 Nov 2026, afternoon): wasm sha256 `053df75ba55af2389a32bf8b93a407635362ea384b6e19a742d0d4c15b62eccf`,
  23 554 429 bytes.
- This build (20 Nov 2026): wasm sha256 `9e186b81d39ae47d08d2d2e5b61d820bbd4ab9c0beb265ffd970d91ae9eb2518`,
  23 610 334 bytes; `rebel_occt.js` byte for byte the second build's. A first try showed that a new build moves
  whatever the kernel names by OCC's order of things: the two saved projects with a closed shell swapped their inner
  faces' names (`<shell>:inner<n>`, the offset's order, which follows where the wasm's memory puts things). Those are
  named from the offset's history now (the commit before this build's); with that, all 130 saved projects regenerated
  the same with this build as with the second (statuses, solids, volumes, face and edge names), before any kernel code
  used the new class.
