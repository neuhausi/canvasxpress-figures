#!/usr/bin/env nextflow
// Figures as pipeline artifacts: one process per spec, then a manifest check.
//   nextflow run nextflow/main.nf -profile docker     # pinned image (ghcr.io/neuhausi/cxplot)
//   nextflow run nextflow/main.nf -profile local      # cxplot on PATH (or params.cxplot)
nextflow.enable.dsl = 2

params.figures  = "${projectDir}/../figures/*.json"
params.manifest = "${projectDir}/../figures.manifest.json"
params.outdir   = "${projectDir}/../out"
params.cxplot   = "cxplot"

process VALIDATE {
    tag "$spec.baseName"
    input:  path spec
    output: path spec
    script: "${params.cxplot} validate ${spec}"
}

process RENDER {
    tag "$spec.baseName"
    publishDir params.outdir, mode: 'copy'
    input:  path spec
    output: path "${spec.baseName}.png"
    script: "${params.cxplot} render ${spec} -o ${spec.baseName}.png"
}

process VERIFY {
    input:  path specs
            path manifest
    output: stdout
    script: "${params.cxplot} hash ${specs} --compare ${manifest}"
}

workflow {
    specs = Channel.fromPath(params.figures)
    VALIDATE(specs) | RENDER
    VERIFY(VALIDATE.out.collect(), file(params.manifest)).view()
}
