process HICCRAMALIGN_CHUNKS {
    label "process_single"

    input:
    tuple val(meta), path(cram), path(crai)
    val cram_bin_size

    output:
    tuple val(meta), val(cram), val(crai), val(chunkn), val(slices), emit: cram_slices
    path("versions.yml")                                           , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    // Note: Manually bump version number when updating module
    def VERSION = "1.0.1"

    def n_slices = crai.countLines(decompress: true) - 1
    def size     = cram_bin_size
    def n_bins   = n_slices.intdiv(size)
    chunkn       = (0..n_bins).collect()
    slices       = chunkn.collect { chunk ->
        def lower = chunk * size
        def upper = [lower + size - 1, n_slices].min()

        return [ lower, upper ]
    }

    """
    cat <<-END_VERSIONS > versions.yml
    HICCRAMALIGN_CHUNKS:
        hiccramalign_chunks: ${VERSION}
    END_VERSIONS
    """
}
