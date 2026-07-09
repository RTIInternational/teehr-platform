locals {
  contour_manifest_raw = replace(
    file("${path.module}/manifests/contour.yaml"),
    "defaultMode: 0644",
    "defaultMode: 420"
  )

  contour_manifest_documents = [
    for doc in split("\n---\n", local.contour_manifest_raw) :
    trimspace(doc)
    if length(regexall("(?m)^\\s*[^#\\s].*$", doc)) > 0
  ]

  contour_manifest_objects_all = [
    for doc in local.contour_manifest_documents : yamldecode(doc)
  ]

  # CRDs and certgen Job are already present and tend to produce provider
  # inconsistency/drift noise during adoption with kubernetes_manifest.
  contour_manifest_objects = [
    for obj in local.contour_manifest_objects_all : obj
    if !contains(["CustomResourceDefinition", "Job"], obj.kind)
  ]
}

resource "kubernetes_manifest" "contour" {
  for_each = {
    for obj in local.contour_manifest_objects :
    "${obj.kind}:${lookup(obj.metadata, "namespace", "cluster")}:${obj.metadata.name}" => obj
  }

  manifest = each.value

  field_manager {
    force_conflicts = true
  }
}
