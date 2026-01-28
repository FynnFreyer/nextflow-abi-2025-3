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
    #!/usr/bin/env python3

    from collections import Counter
    from pathlib import Path
    from operator import itemgetter

    # open and read the normalized word file
    word_path = Path("$word_file")
    with word_path.open() as word_file:
        words = word_file.read().splitlines()

    # do the counting, and sort the results
    counts = Counter(words)
    sorted_words = [
      f"{count} {word}\\n"
      for count, word
      in sorted(counts.items(), key=itemgetter(1))
    ]

    # write the sorted word lines
    out_path = Path("out.counted.txt")
    with out_path.open("w") as out_file:
        out_file.writelines(sorted_words)
    """
}

// cat "out.normalized.txt"

process take_most_common_word {
  input:
    path word_file
  
  output:
    stdout

  script:
    """
    #!/usr/bin/env -S Rscript

    word_counts <- readLines("$word_file")
    last_line <- tail(word_counts, n=1)
    most_common <- strsplit(trimws(last_line), " ")[[1]][1]
    # writeTable("out.counted.txt", most_common, sep=" ")
    # writeLines(most_common, "out.counted.txt")

    cat(most_common)
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
