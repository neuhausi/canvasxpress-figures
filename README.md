# canvasxpress-figures — figures as build artifacts

Every figure in this repository is **regenerated from its spec** by the pipeline, not
pasted in as a screenshot. Each `figures/*.json` is a self-describing CanvasXpress figure
(`{data, config}` — the format every CanvasXpress chart exports and the
[published schema](https://www.canvasxpress.org/spec.html) describes). The pipeline runs
[`cxplot`](https://www.npmjs.com/package/canvasxpress-cli) — the same engine the browser
runs, headless — and verifies the bytes against `figures.manifest.json`.

Three equivalent pipelines, pick yours:

| Pipeline | Run | What it proves |
|---|---|---|
| **Nextflow** | `nextflow run nextflow/main.nf -profile docker` (or `-profile local`) | one process per figure, containerised, resumable |
| **Snakemake** | `snakemake -s snakemake/Snakefile --cores 2` (`--use-singularity`/`--software-deployment-method apptainer` for the image) | DAG: spec → png → manifest check → paper |
| **Quarto** | `quarto render quarto/` after either of the above | the paper embeds the rendered PNGs *and* the live interactive spec |

`.github/workflows/figures.yml` does all three on a clean checkout and fails if any
regenerated figure's SHA-256 differs from the committed manifest.

## Layout

```
figures/*.json            the specs (the source of truth for every figure)
figures.manifest.json     sha256 per figure + engine version — `cxplot hash --manifest`
out/                      regenerated PNGs (git-ignored; CI artifact)
nextflow/main.nf          Nextflow pipeline (+ nextflow.config with docker/local profiles)
snakemake/Snakefile       Snakemake workflow
quarto/paper.qmd          the paper; figures pulled from out/ and embedded live via the
                          canvasxpress Quarto shortcode
scripts/verify.sh         regenerate + compare to the manifest (what CI runs)
```

## Pinning

Reproducibility is engine + renderer + fonts. The Docker image
`ghcr.io/neuhausi/cxplot:<engine>` pins all three (Playwright's Chromium image + the
engine release). `-profile local` / plain `snakemake` use whatever `cxplot` is on `PATH`
(`npm i -g canvasxpress-cli`); the manifest records the engine version so a mismatch is
reported, not silent. Regenerate the manifest deliberately when you upgrade the engine:

```
cxplot hash figures/*.json --manifest figures.manifest.json
```

## Add a figure

1. Export the chart from CanvasXpress (toolbar → Save → JSON) or write the spec by hand.
2. `cxplot validate figures/my-figure.json` — pointer-level errors, nearest legal value.
3. Drop it in `figures/`, reference `out/my-figure.png` (or the live shortcode) in
   `quarto/paper.qmd`, update the manifest, commit. CI does the rest.

## License

MIT for this repository. The CanvasXpress engine is distributed separately under the
CanvasXpress Community License (Attribution) — https://www.canvasxpress.org/license.html.
