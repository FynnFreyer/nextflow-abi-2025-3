process say_hello {
  script:
    """
    echo Hello World!
    """
}

workflow {
  say_hello()
}
