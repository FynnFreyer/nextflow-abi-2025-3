params.in = null

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
  if (params.in == null) {
    println("This is badd!!!")
    exit 1
  }

  ch_input = channel.fromPath(params.in)

  normalize_words(ch_input)
    | count_words
    | take_most_common_word
}
