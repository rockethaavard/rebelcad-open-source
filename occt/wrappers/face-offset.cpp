// Faces of a solid moved along their normals by distances of their own, the other faces kept and extended to meet
// them (move face on curved faces, an offset face): OCCT's BRepOffset_MakeOffset with an offset per face,
// joined by intersection. The class itself is not bound in this build, so this holds one and passes on what Rebel
// CAD needs: the faces' offsets, the build, the result and what each face became (for its name).
#include <BRepOffset_MakeOffset.hxx>
#include <BRepOffset_Mode.hxx>
#include <GeomAbs_JoinType.hxx>
#include <Message_ProgressRange.hxx>
#include <TopoDS.hxx>
#include <TopoDS_Face.hxx>
#include <TopoDS_Shape.hxx>
#include <TopTools_ListOfShape.hxx>

class RebelFaceOffset {
public:
  RebelFaceOffset(const TopoDS_Shape& solid, double tol) {
    mk.Initialize(solid, 0.0, tol, BRepOffset_Skin, Standard_True, Standard_False, GeomAbs_Intersection, Standard_False, Standard_False);
  }
  void SetOffsetOnFace(const TopoDS_Shape& face, double offset) { mk.SetOffsetOnFace(TopoDS::Face(face), offset); }
  bool Build() {
    Message_ProgressRange range;
    mk.MakeOffsetShape(range);
    return mk.IsDone();
  }
  int Error() const { return static_cast<int>(mk.Error()); }
  TopoDS_Shape Shape() const { return mk.Shape(); }
  /** the faces a face of the solid became (empty: unchanged or gone) */
  TopTools_ListOfShape Modified(const TopoDS_Shape& face) { return mk.Modified(face); }
  bool IsDeleted(const TopoDS_Shape& face) { return mk.IsDeleted(face); }

private:
  BRepOffset_MakeOffset mk;
};
