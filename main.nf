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
    path "out.normalized.txt"

  script:
    """
    cat "$word_file" \\
      | tr -d '[:punct:]' \\
      | tr '[:upper:]' '[:lower:]' \\
      | tr -s ' ' '\\n' \\
    > out.normalized.txt
    """
}

process count_words {
  input:
    path word_file
  
  output:
    path "out.counted.txt"

  script:
    """
    cat "$word_file" \\
      | sort \\
      | uniq -c \\
      | sort -n \\
    > out.counted.txt
    """
}

// cat "out.normalized.txt"

process take_most_common_word {
  input:
    path word_file
  
  output:
    path "out.most_common.txt"

  script:
    """
    cat "$word_file" \\
      | tail -1 \\
      | tr -s ' ' \\
      | cut -d ' ' -f 3 \\
    > out.most_common.txt
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
