locals {
  contour_manifest_documents = [
    for doc in split("\n---\n", file("${path.module}/manifests/contour.yaml")) :
    trimspace(doc)
    if trimspace(doc) != "" && !startswith(trimspace(doc), "#")
  ]

  contour_manifest_objects = [
    for doc in local.contour_manifest_documents : yamldecode(doc)
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
