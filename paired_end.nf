#!/usr/bin/env nextflow

process merge_reads {
  input:
    val sample_data

  output:
    stdout
  
  script:
    def sample_id = sample_data[0]
    def (read_1, read_2) = sample_data[1]
    """
    # merge paired end reads
    echo flash -r1 "$read_1" -r2 "$read_2"
    """
}


workflow {
  channel.fromFilePairs("data/samples/*_{R1,R2}.fq") | merge_reads | view
}
