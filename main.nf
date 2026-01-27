#!/usr/bin/env nextflow

params.in = null
params.help = false

def usage() {
  log.info """
SYNOPSIS
  
  nextflow run FynnFreyer/nextflow-abi-2025-3 --in PATH

DESCRIPTION

  This is a word counting script. It takes a file path or
  a glob pattern as input and counts the words in all files.

OPTIONS

  --in    a file path or a glob pattern, e.g., "data/*.txt"

"""
}

process normalize_words {
  input:
    path word_file

  output:
    path "${prefix}.normalized.txt"

  script:
    prefix = word_file.getSimpleName()
    """
    cat "$word_file" \\
      | tr -d '[:punct:]' \\
      | tr '[:upper:]' '[:lower:]' \\
      | tr -s ' ' '\\n' \\
    > "${prefix}.normalized.txt"
    """
}

process count_words {
  input:
    path word_file
  
  output:
    path "${prefix}.counted.txt"

  script:
    prefix = word_file.getSimpleName()
    """
    cat "$word_file" \\
      | sort \\
      | uniq -c \\
      | sort -n \\
    > "${prefix}.counted.txt"
    """
}

process take_most_common_word {
  publishDir("out")

  input:
    path word_file
  
  output:
    path "${prefix}.most_common.txt"

  script:
    prefix = word_file.getSimpleName()
    """
    cat "$word_file" \\
      | tail -1 \\
      | tr -s ' ' \\
      | cut -d ' ' -f 3 \\
    > "${prefix}.most_common.txt"
    """
}

workflow {
  if (params.help) {
    usage()
    exit 0
  }

  if (params.in == null) {
    println("Missing parameter --in!")
    usage()
    exit 1
  }

  ch_input = channel.fromPath(params.in)

  normalize_words(ch_input)
    | count_words
    | take_most_common_word
}
