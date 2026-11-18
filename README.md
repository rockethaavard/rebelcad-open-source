# Rebel CAD: build files of the open source parts

Rebel CAD (https://rebelcad.com, by Rebel Robotics AS) uses open source software. The app's own notices
(`licenses.txt`, "Open source licences" in its user menu) list every part with its licence. This repository holds the
build files those notices point to: what is needed to build, modify and replace the parts whose licences ask for it.

## occt/ : the geometry kernel's WebAssembly build

Rebel CAD's geometry kernel is Open CASCADE Technology (OCCT), unchanged, compiled to WebAssembly and bound to
JavaScript with opencascade.js. `occt/BUILD.md` names the exact upstream commits and the command that builds it;
`occt/custom_build.yml` lists the bound classes; `occt/wrappers/` holds the small helper sources compiled in with it
(replicad's, unchanged, and one of our own, `face-offset.cpp`).

OCCT is under the GNU Lesser General Public License 2.1 with the Open CASCADE exception
(`occt/LICENSE_LGPL_21.txt`, `occt/OCCT_LGPL_EXCEPTION.txt`); the files in `occt/` are offered under the same terms.
The app loads the result as a file of its own (`rebel_occt.wasm` with its loader `rebel_occt.js`), so a build of
yours made with these files can take its place. You may modify these parts for your own use and reverse engineer them
to debug such modifications.

## slicer/ : the container that runs Bambu Studio

Print files are sliced on Rebel CAD's servers by Bambu Studio (AGPL-3.0, https://github.com/bambulab/BambuStudio), run
as a program of its own from its official release, never linked into Rebel CAD. `slicer/` is how that container is
made: the release it downloads and checks (`VERSION`), the image (`Dockerfile`, which copies some of the release's own
preset files to a second folder inside it) and the one-line job script (`slice.sh`). Bambu Studio's source is at the
release named in `VERSION`.

## Questions

contact@rebelcad.com
